extends Spatial

const ENEMY_TYPE = [
	"LIGHT_ATTACKER",
	"HEAVY_ATTACKER",
	"DEFENDER"
]

var _x
var _z

var enemy = load("res://entities/enemies/generic_enemy/Enemy.tscn")

func spawn_enemy():
	var type_choice = ENEMY_TYPE[randi() % ENEMY_TYPE.size()]
	# TODO coś z tym
	var spawned = enemy.instance()
	self.call_deferred("add_child", spawned)
	spawned.init(Vector3(0, 0, 0))
	spawned.connect("died", self, "start_timer")
	print("enemy spawned")

func init(x, y, z):
	self.call_deferred("global_translate", Vector3(x, y, z))
	_x = x
	_z = z
	spawn_enemy()

func start_timer():
	print("Zgoned")
	var t = Timer.new()
	t.set_wait_time(5.0)
	t.autostart = true
	add_child(t)
	yield(t, "timeout")
	t.queue_free()
	spawn_enemy()

func _ready():
	pass
