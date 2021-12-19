extends Node

onready var FIGHT = load("res://scenes/fight/Fight.tscn").instance()
onready var DUNGEON = load("res://scenes/dungeon/Dungeon.tscn")
onready var LOBBY = null
onready var PLAYER = load("res://entities/player/Player.tscn").instance()
onready var MENU = load("res://menus/MainMenu.tscn").instance()

var ROOT
var current_dungeon
onready var _seed = 0
var _current_scene = null

func _ready():
	FIGHT.connect("fight_ended", self, "resolve_fight")

func bind_root(root):
	ROOT = root

func show_menu():
	call_deferred("switch_scene", MENU)

func new_dungeon():
	current_dungeon = DUNGEON.instance()
	var map_dict = Requests.request_map("cave", _seed)
	current_dungeon.init(map_dict, PLAYER)
	call_deferred("switch_scene", current_dungeon)
	#get_tree().root.add_child(current_dungeon)
	#get_tree().change_scene_to(current_dungeon)

func initiate_fight(enemy):
	call_deferred("switch_scene", FIGHT)
	#yield(FIGHT, "tree_entered")
	FIGHT.start_fight(enemy, PLAYER)

func resolve_fight(winner):
	match winner:
		"player":
			print("Player wonnered")
		"enemy":
			print("Ennemy wonnered")
	call_deferred("switch_scene", current_dungeon)

func switch_scene(new_scene):
	print("Called to switch from:")
	print(_current_scene)
	print("To:")
	print(new_scene)
	print("Before:")
	print(ROOT.get_children())
	ROOT.add_child(new_scene)
	#ROOT.call_deferred("add_child", new_scene)
	if _current_scene != null:
		ROOT.remove_child(_current_scene)
		#ROOT.call_deferred("remove_child", _current_scene)
	_current_scene = new_scene
	print("After:")
	print(ROOT.get_children())
