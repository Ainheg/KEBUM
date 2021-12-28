extends KinematicBody

var stats
var type
var level

var current_health = 50.0
var max_health = 50.0
var dead = false

onready var rng = RandomNumberGenerator.new()

signal health_changed
signal enemy_died

func init(trans_vec):
	yield(self, "ready") 
	self.translate(trans_vec)

func _ready():
	self.type = EnemyConsts.types[randi() % EnemyConsts.types.size()]
	self.level = Main.get_world_level()
	self.stats = randomize_stats()
	rng.randomize()
	print(stats)

func die():
	self.queue_free()

func randomize_stats():
	var rnd_stats = {
		"STR" : 0,
		"AGI" : 0,
		"PER" : 0,
		"DEF" : 0,
		"LCK" : 0,
		"CST" : 0
	}
	
	for _i in range(level - 1):
		rnd_stats[EnemyConsts.type_stat_distribution[type][randi() % EnemyConsts.type_stat_distribution[type].size()]] += 1
	
	return rnd_stats

func recalculate_max_health():
	self.max_health = EnemyConsts.health + 25.0 * get_stats()["CST"]

func get_current_health():
	return self.current_health

func get_max_health():
	recalculate_max_health()
	return self.max_health

func add_health(value):
	self.current_health += value
	recalculate_max_health()
	if self.current_health >= max_health:
		self.current_health = max_health
	emit_signal("health_changed", current_health)
	if self.current_health <= 0 and !dead:
		dead = true
		emit_signal("enemy_died")

func get_moves():
	var moveset = []
	for _i in range(3):
		moveset.append(EnemyConsts.attack_types[type][rng.randi() % EnemyConsts.attack_types[type].size()])
	return moveset

func get_stats():
	return stats

func get_derived_stats():
	var derived_stats = {
		"ATK_PWR" : EnemyConsts.attack_power + 10.0 * stats["STR"],
		"ARMOR" : EnemyConsts.armor + 5.0 * stats["DEF"],
		"CRIT_DMG" : EnemyConsts.crit_dmg + 0.05 * stats["STR"],
		"CRIT_CHANCE" : EnemyConsts.crit_chance + 0.025 * stats["LCK"],
		"EVA_CHANCE" : EnemyConsts.eva_chance + 0.015 * stats["AGI"],
		"ACCURACY" : EnemyConsts.accuracy + 0.01 * stats["AGI"],
		"REV_CHANCE" : EnemyConsts.rev_chance + 0.1 * stats["PER"],
		"LIFESTEAL" : EnemyConsts.lifesteal + 0.025 * stats["CST"]
	}
	return derived_stats
