extends Node

const BP_SIZE = 25

signal inventory_updated

onready var CHEATING_CHARM = Items.Item.new("Cheating Charm",
			 "Legendary",
			 "Charm",
			 {"STR" : 30, "AGI" : 30, "PER" : 30, "DEF" : 30, "LCK" : 30, "CST" : 30},
			 {})
onready var BASIC_STICK = Items.Item.new("Basic Stick",
			 "Common",
			 "Weapon",
			 {"STR" : 1, "AGI" : 0, "PER" : 0, "DEF" : 0, "LCK" : 0, "CST" : 0},
			 {})

onready var equipped = {
	"Headgear" : null,
	"Armor" : null,
	"Weapon" : BASIC_STICK,
	"Charm" : null
}

onready var backpack = [
	CHEATING_CHARM
]

func can_add_item():
	return backpack.has(null)

func add_item(item):
	var idx = backpack.find(null)
	if idx != -1:
		backpack[idx] = item

func clear():
	equipped = {
	"Headgear" : null,
	"Armor" : null,
	"Weapon" : BASIC_STICK,
	"Charm" : null
	}
	backpack = [CHEATING_CHARM]
	backpack.resize(BP_SIZE)

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
