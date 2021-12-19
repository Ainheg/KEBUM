extends KinematicBody

var stats

signal died

func init(trans_vec): 
	#self.translate(trans_vec)
	call_deferred("translate", trans_vec)

func _ready():
	self.stats = randomize_stats(PlayerAttributes.level)
	pass

func die():
	emit_signal("died")
	call_deferred("queue_free")

func randomize_stats(level):
	stats = {
		"STR" : 1,
		"AGI" : 1,
		"PER" : 1,
		"DEF" : 1,
		"LCK" : 1,
		"CST" : 1
	}

func get_moves():
	return ["attack", "block", "pierce"]

func get_stats():
	return stats
