extends Node

const BP_SIZE = 25

signal inventory_updated

onready var equipped = {
	"Headgear" : null,
	"Armor" : null,
	"Weapon" : Items.Item.new("Zwykły Kij",
			 "Common",
			 "Weapon",
			 {"STR" : 1, "AGI" : 0, "PER" : 0, "DEF" : 0, "LCK" : 0, "CST" : 0},
			 {}),
	"Charm" : null
}

onready var backpack = [
	Items.Item.new("Zaklęty Miecz",
			 "Epic",
			 "Weapon",
			 {"STR" : 1, "AGI" : 0, "PER" : 0, "DEF" : 0, "LCK" : 0, "CST" : 1},
			 {}),
	Items.Item.new("Kamizelka",
			 "Rare",
			 "Armor",
			 {"STR" : 1, "AGI" : 2, "PER" : 0, "DEF" : 0, "LCK" : 0, "CST" : 3},
			 {}),
	Items.Item.new("Fedora",
			 "Epic",
			 "Headgear",
			 {"STR" : 0, "AGI" : 0, "PER" : 0, "DEF" : 3, "LCK" : 2, "CST" : 0},
			 {}),
	Items.Item.new("Cheating Charm",
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
