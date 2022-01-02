extends Spatial

func _ready():
	pass

func init(x, y, z):
	yield(self, "ready")
	global_translate(Vector3(x, y, z))
