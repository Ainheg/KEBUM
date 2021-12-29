extends Node

const BP_SIZE = 25

signal inventory_updated

var equipped = {
	"Headgear" : null,
	"Armor" : null,
	"Weapon" : 	Item.new("Zwykły Kij",
			 "Common",
			 "Weapon",
			 {"STR" : 1, "AGI" : 0, "PER" : 0, "DEF" : 0, "LCK" : 0, "CST" : 0},
			 {},
			 null),
	"Charm" : null
}

var backpack = [
	Item.new("Zaklęty Miecz",
			 "Common",
			 "Weapon",
			 {"STR" : 1, "AGI" : 0, "PER" : 0, "DEF" : 0, "LCK" : 0, "CST" : 1},
			 {},
			 null)
]

func can_add_item():
	return backpack.has(null)

func add_item(item):
	var idx = backpack.find(null)
	if idx != -1:
		backpack[idx] = item

func _ready():
	backpack.resize(BP_SIZE)

func _equip_item(idx):
	if backpack[idx] == null:
		 return
	var tmp = backpack[idx]
	var item_type = tmp.get_type()
	backpack[idx] = equipped[item_type]
	equipped[item_type] = tmp
	emit_signal("inventory_updated")

func _remove_item(idx):
	backpack[idx] = null
	emit_signal("inventory_updated")

class Item:
	
	var name : String
	var rarity : String
	var type : String
	var stats : Dictionary
	var bonuses : Dictionary
	var image
	var tooltip : String
	
	func _init(name, rarity, type, stats, bonuses, image):
		self.name = name
		self.rarity = rarity
		self.type = type
		self.stats = stats
		self.bonuses = bonuses
		self.image = image
		self.tooltip = generate_tooltip()
	
	func generate_tooltip():
		var tooltip = "%s %s\n" % [rarity, name]
		tooltip += "%s\n" % type
		for stat in stats:
			if stats[stat] != 0:
				tooltip += "%s : %d\n" % [stat, stats[stat]]
		return tooltip
	
	func get_type():
		return type
	
	func get_tooltip():
		return tooltip
	
	func get_stats():
		return stats
	
	func get_bonuses():
		return bonuses
	
	func get_image():
		return image
