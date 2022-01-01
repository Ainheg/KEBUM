extends Spatial

# A generic dungeon
var _map_grid
var _map_height
var _map_width
var _treasure_locations
var _enemy_spawn_points
var _map_type
var _hint_location
var _entrance
var _exit

var spawner = load("res://entities/enemies/generic_enemy/Spawner.tscn")
var treasure_container = load("res://scenes/dungeon/treasure/TreasureContainer.tscn")
var _player

func init(map_dict, player):
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
			$Terrain.set_cell_item(x, 0, z, item)
	print("Dungeon scene created")
	_place_spawners()
	_place_treasure()
	self._player = player
	self.call_deferred("add_child", player)
	_place_player()

func _place_spawners():
	var cell_scale = $Terrain.get_cell_size()
	for spawn_point in _enemy_spawn_points:
		var x = spawn_point[0]
		var z = spawn_point[1]
		var s = spawner.instance()
		$SpawnPoints.call_deferred("add_child", s)
		s.init(x * cell_scale[0], 0.5, z * cell_scale[2])

func _place_treasure():
	var cell_scale = $Terrain.get_cell_size()
	for coordinates in _treasure_locations:
		var x = coordinates[0]
		var z = coordinates[1]
		var t = treasure_container.instance()
		$Treasure.call_deferred("add_child", t)
		t.init(x * cell_scale[0], 0.5, z * cell_scale[2], false)
	var x = _hint_location[0]
	var z = _hint_location[1]
	var t = treasure_container.instance()
	$Treasure.call_deferred("add_child", t)
	t.init(x * cell_scale[0], 0.5, z * cell_scale[2], true)
	

func _place_player():
	var cell_scale = $Terrain.get_cell_size()
	self._player.init(_entrance[0] * cell_scale[0], 0.5, _entrance[1] * cell_scale[2])

func _ready():
	print($Terrain.mesh_library.get_item_mesh(0))
	pass

