extends Node

onready var FIGHT = load("res://scenes/fight/Fight.tscn").instance()
onready var DUNGEON = load("res://scenes/dungeon/Dungeon.tscn")
onready var LOBBY = null
onready var PLAYER = load("res://entities/player/Player.tscn").instance()
onready var MENU = load("res://menus/MainMenu.tscn").instance()
onready var OVERLAY = load("res://ui/overlay/Overlay.tscn").instance()

var world_level
var ROOT
var current_dungeon
onready var _seed = 0
var _current_scene = null

func _ready():
	FIGHT.connect("fight_ended", self, "resolve_fight")
	PLAYER.connect("ready", self, "_init_overlay")

func bind_root(root):
	ROOT = root

func show_menu():
	call_deferred("switch_scene", MENU)

func new_dungeon():
	world_level = PLAYER.level
	current_dungeon = DUNGEON.instance()
	var map_dict = Requests.request_map("cave", _seed)
	current_dungeon.init(map_dict, PLAYER)
	call_deferred("switch_scene", current_dungeon)
	show_overlay()

func initiate_fight(enemy):
	call_deferred("switch_scene", FIGHT)
	#yield(FIGHT, "tree_entered")
	print("Inside main: ")
	print(enemy)
	FIGHT.start_fight(enemy, PLAYER)
	hide_overlay()

func resolve_fight(winner):
	match winner:
		"player":
			print("Player wonnered")
		"enemy":
			print("Ennemy wonnered")
	call_deferred("switch_scene", current_dungeon)
	show_overlay()

func _init_overlay():
	ROOT.add_child(OVERLAY)
	OVERLAY.init()

func show_overlay():
	OVERLAY.visible = true

func hide_overlay():
	OVERLAY.visible = false

func get_world_level():
	return world_level

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
