extends KinematicBody

# SIGNALS
signal player_died
signal health_changed(current_health, max_health)
signal level_up(old_level, current_level)
signal xp_gained(old_xp, new_xp)
signal stat_increased

# LEVEL AND XP
const MAX_LEVEL = 30
var level = 1
var experience = 0
var upgrade_count = 1

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

var max_health = 50.0
var current_health = 50.0
var dead = false

# MOVEMENT VARIABLES
var speed = 600
var sensitivity = 0.15
onready var gimbal = get_node("Gimbal")

# INVENTORY
onready var inventory = get_node("/root/PlayerInventory")

func init(x, y, z):
	global_translate(Vector3(x, y, z))
	set_camera()
	if dead:
		reset_stats()

func _ready():
	print("Player ready")
	inventory.connect("inventory_updated", self, "restore_health")

func _input(event):
	if !is_inside_tree():
		return
	
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
	
	if event is InputEventMouseMotion:
		var movement = event.relative
		gimbal.rotation.z += -deg2rad(movement.y * sensitivity)
		gimbal.rotation.z = clamp(gimbal.rotation.z, deg2rad(-90), deg2rad(90))
		rotation.y += -deg2rad(movement.x * sensitivity)

func _physics_process(delta):
	if !is_inside_tree():
		return
	
	var velocity = Vector2.ZERO

	if Input.is_action_pressed("move_forward"):
		velocity.x += 1
	if Input.is_action_pressed("move_backward"):
		velocity.x -= 1
	if Input.is_action_pressed("move_left"):
		velocity.y -= 1
	if Input.is_action_pressed("move_right"):
		velocity.y += 1
	velocity = velocity.normalized().rotated(-rotation.y)
	velocity = Vector3(
		velocity.x * speed * delta,
		0,
		velocity.y * speed * delta
	)
	call_deferred("move_and_slide", velocity)

func set_camera():
	$Gimbal/Camera.make_current()

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
		var item_stats = item.get_stats()
		for stat in item_stats:
			cur_stats[stat] += item_stats[stat]
	return cur_stats

func get_derived_stats():
	var cur_stats = get_stats_with_items()
	
	var derived_stats = {
		"ATK_PWR" : attack_power + 10.0 * cur_stats["STR"],
		"ARMOR" : armor + 5.0 * cur_stats["DEF"],
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
	max_health = health + 25.0 * get_stats_with_items()["CST"]

func restore_health():
	recalculate_max_health()
	add_health(max_health)

func add_health(value):
	current_health += value
	recalculate_max_health()
	if current_health >= max_health:
		current_health = max_health
	emit_signal("health_changed", current_health)
	if current_health <= 0 and !dead:
		dead = true
		call_deferred("emit_signal", "player_died")

func get_current_health():
	return current_health

func get_max_health():
	recalculate_max_health()
	return max_health

func get_xp():
	return experience

func get_xp_for_next_level():
	return 100

func get_level():
	return level

func get_upgrade_count():
	return upgrade_count

func add_xp(value):
	print("Gained " + str(value) + " xp")
	while value > 0:
		if experience + value >= get_xp_for_next_level():
			emit_signal("xp_gained", experience, get_xp_for_next_level())
			value -= get_xp_for_next_level() - experience
			level_up()
		else:
			emit_signal("xp_gained", experience, experience + value)
			experience += value
			value = 0

func level_up():
	experience = 0
	level += 1
	upgrade_count += 1
	emit_signal("level_up", level - 1, level)

func _on_stat_increased(stat):
	if upgrade_count <= 0:
		return
	match stat:
		"STR":
			STR += 1
		"AGI":
			AGI += 1
		"PER":
			PER += 1
		"DEF":
			DEF += 1
		"LCK":
			LCK += 1
		"CST":
			CST += 1
			recalculate_max_health()
			restore_health()
	upgrade_count -= 1
	emit_signal("stat_increased")

func reset_stats():
	experience = 0
	level = 1
	upgrade_count = 0
	dead = false
	STR = 0
	AGI = 0
	PER = 0
	DEF = 0
	LCK = 0
	CST = 0
	recalculate_max_health()
	restore_health()
	#inventory.clear()

func _on_Proximity_body_entered(body):
	if !body.has_method("identify"):
		return
	match body.identify():
		"Enemy":
			print("Enemy encountered")
			Main.initiate_fight(body)

func identify():
	return "Player"
