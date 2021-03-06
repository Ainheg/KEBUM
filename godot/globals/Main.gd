extends Node

const MAX_DAYS = 3
const MAX_ROUNDS = 5

onready var FIGHT = load("res://scenes/fight/Fight.tscn").instance()
onready var DUNGEON = load("res://scenes/dungeon/Dungeon.tscn")
onready var LOBBY = load("res://menus/lobby/Lobby.tscn").instance()
onready var BOSS = load("res://entities/enemies/boss/Boss.tscn").instance()
onready var PLAYER = load("res://entities/player/Player.tscn").instance()
onready var MENU = load("res://menus/main_menu/MainMenu.tscn").instance()
onready var OVERLAY = load("res://ui/overlay/Overlay.tscn").instance()

var world_level
var ROOT
var current_dungeon
onready var dungeon_types = ["cave", "outdoor", "indoor"]

var current_round = 1
var current_day = 1
var bossfight_day = false

onready var dungeon_seed = 0
onready var game_seed = 0
onready var game_rng = RandomNumberGenerator.new()
var _current_scene = null

func _ready():
	randomize()
	game_seed = randi()
	dungeon_seed = randi()
	FIGHT.connect("fight_ended", self, "resolve_fight")
	PLAYER.connect("ready", self, "_init_overlay")

func bind_root(root):
	ROOT = root

func unbind_player():
	PLAYER.get_parent().remove_child(PLAYER)

func show_menu():
	hide_overlay()
	call_deferred("switch_scene", MENU)
	show_mouse()

func show_lobby():
	hide_overlay()
	show_mouse()
	call_deferred("switch_scene", LOBBY)

func new_dungeon():
	world_level = PLAYER.level
	
	# Unbind player and remove old dungeon
	if current_dungeon != null:
		unbind_player()
		current_dungeon.queue_free()
	
	print("Dungeon initializing")
	current_dungeon = DUNGEON.instance()
	var map_dict = Requests.request_map(get_next_dungeon_type(), hash(dungeon_seed))
	Items.setup_rng(hash(hash(game_seed) + current_day + current_round))
	current_dungeon.init(map_dict, PLAYER)
	call_deferred("switch_scene", current_dungeon)
	show_overlay()
	hide_mouse()

func exit_dungeon():
	dungeon_seed = hash(game_rng.randi())
	current_day = ( current_day + 1 ) % ( MAX_DAYS + 1 )
	show_lobby()
	
	if bossfight_day:
		current_round += 1
		if current_round == MAX_ROUNDS + 1:
			show_menu()
			return
		new_round()

	if current_day == 0:
		bossfight_day = true
	else:
		bossfight_day = false

func initiate_fight(enemy):
	call_deferred("switch_scene", FIGHT)
	FIGHT.start_fight(enemy, PLAYER)
	hide_overlay()
	show_mouse()

func resolve_fight(winner):
	match winner:
		"player":
			if !bossfight_day:
				call_deferred("switch_scene", current_dungeon)
				show_overlay()
				hide_mouse()
			else:
				exit_dungeon()
		"enemy":
			print("Game over")
			PLAYER.reset_stats()
			OVERLAY.reset()
			show_menu()

func _init_overlay():
	ROOT.add_child(OVERLAY)
	OVERLAY.init()

func show_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func show_overlay():
	OVERLAY.visible = true

func hide_overlay():
	OVERLAY.visible = false

func get_world_level():
	return world_level

func is_bossfight_day():
	return bossfight_day

func get_next_dungeon_type():
	if bossfight_day:
		return "none today :D"
	else:
		return dungeon_types[current_day - 1]

func switch_scene(new_scene):
	print("Called to switch from:")
	print(_current_scene)
	print("To:")
	print(new_scene)
	print("Before:")
	print(ROOT.get_children())
	ROOT.add_child(new_scene)
	if _current_scene != null:
		ROOT.remove_child(_current_scene)
	_current_scene = new_scene
	print("After:")
	print(ROOT.get_children())

func new_boss():
	var boss_dict = Requests.request_boss(EnemyConsts.BOSS_LEVELS[current_round], hash(hash(game_seed) + current_round))
	BOSS.init(boss_dict)

func new_game():
	current_day = 1
	current_round = 1
	bossfight_day = false
	game_rng.seed = hash(game_seed)
	new_round()
	hide_overlay()
	show_mouse()
	switch_scene(LOBBY)

func new_round():
	dungeon_seed = hash(game_rng.randi())
	dungeon_types.shuffle()
	new_boss()
