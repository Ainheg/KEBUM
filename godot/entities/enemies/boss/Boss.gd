extends Node

var boss_name
var level
var stats
var moveset
var items = {
	"Headgear" : null,
	"Armor" : null,
	"Weapon" : null,
	"Charm" : null
}
var hints
var hints_uncovered

var current_health = 50.0
var max_health = 50.0
var dead = false

var rng = RandomNumberGenerator.new()

signal health_changed
signal enemy_died

func init(boss_dict):
	self.boss_name = boss_dict["boss_name"]
	self.level = boss_dict["level"]
	self.moveset = boss_dict["moveset"]
	self.stats = boss_dict["stats"]
	for item_type in items:
		var item_dict = boss_dict["items"][item_type]
		items[item_type] = Items.Item.new(
			item_dict["name"],
			item_dict["rarity"],
			item_dict["type"],
			item_dict["stats"],
			item_dict["bonuses"]
		)
	self.hints = boss_dict["hints"]
	self.hints_uncovered = [false, false, false]
	restore_health()

func _ready():
	rng.randomize()

func die():
	self.queue_free()

func get_stats():
	return stats

func get_stats_with_items():
	var cur_stats = get_stats()

	# Add stats from items
	for item in items.values():
		if item == null:
			continue
		var item_stats = item.get_stats()
		for stat in item_stats:
			cur_stats[stat] += item_stats[stat]
	return cur_stats

func get_derived_stats():
	var cur_stats = get_stats_with_items()
	
	var derived_stats = {
		"ATK_PWR" : EnemyConsts.attack_power + 10.0 * cur_stats["STR"],
		"ARMOR" : EnemyConsts.armor + 5.0 * cur_stats["DEF"],
		"CRIT_DMG" : EnemyConsts.crit_dmg + 0.05 * cur_stats["STR"],
		"CRIT_CHANCE" : EnemyConsts.crit_chance + 0.025 * cur_stats["LCK"],
		"EVA_CHANCE" : EnemyConsts.eva_chance + 0.015 * cur_stats["AGI"],
		"ACCURACY" : EnemyConsts.accuracy + 0.01 * cur_stats["AGI"],
		"REV_CHANCE" : EnemyConsts.rev_chance + 0.1 * cur_stats["PER"],
		"LIFESTEAL" : EnemyConsts.lifesteal + 0.025 * cur_stats["CST"]
	}
		
	var percentage_bonuses = {}
	for item in items.values():
		if item == null:
			continue
		var bonuses = item.get_bonuses()
		for bonus in bonuses:
			var value = bonuses[bonus]
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

func recalculate_max_health():
	self.max_health = EnemyConsts.health + 25.0 * get_stats_with_items()["CST"]

func restore_health():
	recalculate_max_health()
	add_health(max_health)

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
	var moves = []
	for _i in range(3):
		moves.append(self.moveset[rng.randi() % self.moveset.size()])
	return moves

func get_name():
	return boss_name

func get_level():
	return level

func get_hint(idx):
	if hints_uncovered[idx]:
		return hints[idx]
	else:
		return "Not found"

func get_new_hint(idx):
	return hints[idx]

func uncover_hint():
	var hint_no = Main.current_day - 1
	self.hints_uncovered[hint_no] = true
	print("Hint uncovered")
