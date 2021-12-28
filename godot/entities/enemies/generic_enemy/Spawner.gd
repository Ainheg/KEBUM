extends Spatial

var _x
var _z

var enemy = load("res://entities/enemies/generic_enemy/Enemy.tscn")

func spawn_enemy():
	var spawned = enemy.instance()
	self.call_deferred("add_child", spawned)
	spawned.init(Vector3(0, 0, 0))
	spawned.connect("enemy_died", self, "start_timer")

func init(x, y, z):
	yield(self, "ready")
	global_translate(Vector3(x, y, z))
	_x = x
	_z = z
	spawn_enemy()

func start_timer():
	var t = Timer.new()
	t.set_wait_time(5.0)
	t.autostart = true
	add_child(t)
	yield(t, "timeout")
	t.queue_free()
	spawn_enemy()

func _ready():
	pass
