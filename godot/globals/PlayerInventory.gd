extends Node

onready var ITEM_TEXTURES = {
	"Weapon" : {
		"Common" : load("res://ui/inventory/assets/items/weapon-common.png"),
		"Rare" : load("res://ui/inventory/assets/items/weapon-rare.png"),
		"Epic" : load("res://ui/inventory/assets/items/weapon-epic.png"),
		"Legendary" : load("res://ui/inventory/assets/items/weapon-legendary.png")
	},
	"Armor" : {
		"Common" : load("res://ui/inventory/assets/items/armor-common.png"),
		"Rare" : load("res://ui/inventory/assets/items/armor-rare.png"),
		"Epic" : load("res://ui/inventory/assets/items/armor-epic.png"),
		"Legendary" : load("res://ui/inventory/assets/items/armor-legendary.png")
	},
	"Headgear" : {
		"Common" : load("res://ui/inventory/assets/items/headgear-common.png"),
		"Rare" : load("res://ui/inventory/assets/items/headgear-rare.png"),
		"Epic" : load("res://ui/inventory/assets/items/headgear-epic.png"),
		"Legendary" : load("res://ui/inventory/assets/items/headgear-legendary.png")
	},
	"Charm" : {
		"Common" : load("res://ui/inventory/assets/items/charm-common.png"),
		"Rare" : load("res://ui/inventory/assets/items/charm-rare.png"),
		"Epic" : load("res://ui/inventory/assets/items/charm-epic.png"),
		"Legendary" : load("res://ui/inventory/assets/items/charm-legendary.png")
	}
}

const BP_SIZE = 25

signal inventory_updated

var equipped = {
	"Headgear" : null,
	"Armor" : null,
	"Weapon" : Item.new("Zwykły Kij",
			 "Common",
			 "Weapon",
			 {"STR" : 1, "AGI" : 0, "PER" : 0, "DEF" : 0, "LCK" : 0, "CST" : 0},
			 {}),
	"Charm" : null
}

var backpack = [
	Item.new("Zaklęty Miecz",
			 "Epic",
			 "Weapon",
			 {"STR" : 1, "AGI" : 0, "PER" : 0, "DEF" : 0, "LCK" : 0, "CST" : 1},
			 {}),
	Item.new("Kamizelka",
			 "Rare",
			 "Armor",
			 {"STR" : 1, "AGI" : 2, "PER" : 0, "DEF" : 0, "LCK" : 0, "CST" : 3},
			 {}),
	Item.new("Fedora",
			 "Epic",
			 "Headgear",
			 {"STR" : 0, "AGI" : 0, "PER" : 0, "DEF" : 3, "LCK" : 2, "CST" : 0},
			 {}),
	Item.new("Cheating Charm",
			 "Legendary",
			 "Charm",
			 {"STR" : 99, "AGI" : 99, "PER" : 99, "DEF" : 99, "LCK" : 99, "CST" : 99},
			 {})
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

func _unequip_item(item_type):
	if !can_add_item():
		 return
	add_item(equipped[item_type])
	equipped[item_type] = null
	emit_signal("inventory_updated")

func _remove_item(idx):
	backpack[idx] = null
	emit_signal("inventory_updated")

func _remove_equipped_item(item_type):
	equipped[item_type] = null
	emit_signal("inventory_updated")

########################################
####           ITEM CLASS           ####
########################################

class Item:
	
	var name : String
	var rarity : String
	var type : String
	var stats : Dictionary
	var bonuses : Dictionary
	var tooltip : String
	
	func _init(name, rarity, type, stats, bonuses):
		self.name = name
		self.rarity = rarity
		self.type = type
		self.stats = stats
		self.bonuses = bonuses
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
	
	func get_rarity():
		return rarity
	
	func get_tooltip():
		return tooltip
	
	func get_stats():
		return stats
	
	func get_bonuses():
		return bonuses
