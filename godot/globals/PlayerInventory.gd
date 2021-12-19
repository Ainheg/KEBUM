extends Node

const BP_SIZE = 20

var equipped = {
	"Headgear" : null,
	"Armor" : null,
	"Weapon" : null,
	"Charm" : null
}

var backpack = {}

func add_item(item, idx=null):
	if idx != null:
		if backpack.has(idx):
			pass # TODO

func _ready():
	pass
