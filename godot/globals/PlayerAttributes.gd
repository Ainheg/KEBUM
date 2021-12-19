extends Node

# LEVEL AND XP
var level = 1
var experience = 0

# MACRO STATS
var STR = 0
var AGI = 0
var PER = 0
var DEF = 0
var LCK = 0
var CST = 0

# BASE DERIVED STATS
const attack_power = 20.0
const armor = 10.0
const health = 50.0
const crit_dmg = 1.3
const crit_chance = 0.05
const eva_chance = 0.03
const accuracy = 0.9
const rev_chance = 0.01
const lifesteal = 0.0


func increase_stats(strength=0, agility=0, perception=0, defense=0, luck=0, constitution=0):
	STR += strength
	AGI += agility
	PER += perception
	DEF += defense
	LCK += luck
	CST += constitution

# INVENTORY
onready var inventory = get_node("/root/PlayerInventory")

func get_stats():
	return {
		"STR" : STR,
		"AGI" : AGI,
		"PER" : PER,
		"DEF" : DEF,
		"LCK" : LCK,
		"CST" : CST
	}

func get_stats_with_items():
	var cur_stats = get_stats()

	# Add stats from items
	for item in inventory.equipped.values():
		if item == null:
			continue
		for stat in item.stats:
			cur_stats[stat] += item.stats[stat]
	return cur_stats

func get_derived_stats():
	var cur_stats = get_stats_with_items()
	var derived_stats = {
		"ATK_PWR" : attack_power + 10.0 * cur_stats["STR"],
		"ARMOR" : armor + 5.0 * cur_stats["DEF"],
		"HP" : health + 25.0 * cur_stats["CST"],
		"CRIT_DMG" : crit_dmg + 0.05 * cur_stats["STR"],
		"CRIT_CHANCE" : crit_chance + 0.025 * cur_stats["LCK"],
		"EVA_CHANCE" : eva_chance + 0.015 * cur_stats["AGI"],
		"ACCURACY" : accuracy + 0.01 * cur_stats["AGI"],
		"REV_CHANCE" : rev_chance + 0.1 * cur_stats["PER"],
		"LIFESTEAL" : lifesteal + 0.025 * cur_stats["CST"]
	}
		
	var percentage_bonuses = {}
	for item in inventory.equipped.values():
		if item == null:
			continue
		for bonus in item.bonuses:
			var value = item.bonuses[bonus]
			if "%" in bonus:
				var bonus_name = bonus.substr(2, len(bonus)-1)
				if bonus_name in percentage_bonuses:
					percentage_bonuses[bonus_name] *= value
				else:
					percentage_bonuses[bonus_name] = value
				continue
			derived_stats[bonus] += value
	for bonus in percentage_bonuses:
		var value = percentage_bonuses[bonus]
		derived_stats[bonus] *= value

	return derived_stats

func _ready():
	pass
