extends Node

const types = ["attacker", "defender", "piercer"]

const type_stat_distribution = {
	"attacker" : ["STR", "STR", "STR", "AGI", "AGI", "PER", "DEF", "LCK", "LCK", "CST"],
	"defender" : ["STR", "AGI", "PER", "DEF", "DEF", "DEF", "LCK", "CST", "CST", "CST"],
	"piercer" : ["STR", "STR", "AGI", "PER", "DEF", "LCK", "LCK", "CST"]
}

const attack_types = {
	"attacker" : ["attack", "attack", "attack", "attack", "attack", "pierce", "pierce", "block"], # 5/8 attack, 2/8 pierce, 1/8 block  
	"defender" : ["attack", "attack", "pierce", "block", "block", "block", "block", "block"], # 5/8 block, 2/8 attack, 1/8 pierce
	"piercer" : ["attack", "attack", "pierce", "pierce", "pierce", "pierce", "pierce", "block"] # 5/8 pierce, 2/8 attack, 1/8 block
}

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

func _ready():
	pass
