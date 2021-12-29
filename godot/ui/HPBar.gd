extends Container

var max_health
var current_health

func init(current_health, max_health):
	self.max_health = max_health
	update_counter(current_health)

func _on_health_changed(new_health):
	update_counter(new_health)

func update_counter(new_health):
	$Counter/Value.text = '%.1f/' % new_health + '%.1f' % max_health
	$Counter/Value.text = '%.1f/' % new_health + '%.1f' % max_health
	current_health = new_health

func animate_change(new_health):
	$Tween.interpolate_method(self, "update_counter", current_health, new_health, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()

func _ready():
	pass
