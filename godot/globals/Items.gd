extends Node

onready var rng = RandomNumberGenerator.new()

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

onready var BONUSES = {
	"ATK_PWR" : "Attack power",
	"ARMOR" : "Armor",
	"CRIT_DMG" : "Crit damage",
	"CRIT_CHANCE" : "Crit chance",
	"%_ATK_PWR" : "Attack power",
	"%_ARMOR" : "Armor",
}

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
		for bonus in bonuses:
			if bonus.begins_with("%"):
				if bonuses[bonus] != 1.0:
					tooltip += "%s : %d%%\n" % [Items.BONUSES[bonus], int((bonuses[bonus] - 1.0) * 100)]
				continue
			if "CRIT" in bonus:
				tooltip += "%s : %.2f\n" % [Items.BONUSES[bonus], bonuses[bonus]]
				continue
			if bonuses[bonus] != 0:
				tooltip += "%s : %d\n" % [Items.BONUSES[bonus], bonuses[bonus]]
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


func _ready():
	pass

func setup_rng(game_seed):
	rng.seed = hash(game_seed)

func get_new_item_seed():
	return rng.randi()
