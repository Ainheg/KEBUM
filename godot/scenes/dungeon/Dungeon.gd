extends Spatial

# A generic dungeon
var player = load("res://entities/player/Player.tscn").instance()
var _map_grid
var _map_height
var _map_width
var _treasure_locations
var _enemy_spawn_points
var _map_type
var _hint_location
var _entrance
var _exit



func init(map_dict):
	"""Initializes a Dungeon-class object, takes in dictionary map_dict"""
	_map_grid = map_dict["grid"]
	_map_height = len(_map_grid)
	_map_width = len(_map_grid[0])
	_treasure_locations = map_dict["treasure_locations"]
	_hint_location = map_dict["hint_location"]
	_enemy_spawn_points = map_dict["spawn_points"]
	_map_type = map_dict["map_type"]
	_entrance = map_dict["entrance"]
	_exit = map_dict["exit"]
	print(_entrance)
	print(_exit)
	for z in range(_map_height):
		for x in range(_map_width):
			var item = _map_grid[z][x]
			if item == 2:
				item = 1
			$Terrain.set_cell_item(x - int(_map_width/2), 0, z - int(_map_height/2), item)
	print("Dungeon scene created")
	$Camera.make_current()
	print(get_viewport().get_camera())
	_place_player()

func _place_player():
	self.add_child(player)
	var cell_scale = $Terrain.get_cell_size()
	player.init(_entrance[0] * cell_scale[0], 1, _entrance[1] * cell_scale[2])

func _ready():
	pass

