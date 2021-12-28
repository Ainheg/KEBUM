extends MarginContainer

onready var BAR = $BarContainer/BarVBContainer/BarMargin/Bar
onready var XP_LABEL = $BarContainer/BarVBContainer/Label
onready var LVL_LABEL = $LevelARContainer/LevelCContainer/Label
var max_xp

func init():
	max_xp = Main.PLAYER.get_xp_for_next_level()
	BAR.max_value = max_xp
	BAR.value = Main.PLAYER.get_xp()
	update_level_label(Main.PLAYER.get_level())
	update_xp_counter(Main.PLAYER.get_xp())
	Main.PLAYER.connect("xp_gained", self, "_on_xp_ammount_changed")
	Main.PLAYER.connect("level_up", self, "_on_level_up")

func animate_level_change(old_level, new_level):
	$Tween.interpolate_method(self, "update_level_label", old_level, new_level, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()

func animate_xp_change(old_xp, new_xp):
	$Tween.interpolate_property(BAR, "value", old_xp, new_xp, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$Tween.interpolate_method(self, "update_xp_counter", old_xp, new_xp, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()

func update_xp_counter(value):
	XP_LABEL.text = str(value) + '/' + str(max_xp)

func update_level_label(value):
	LVL_LABEL.text = str(value)

func _on_level_up(old_level, new_level):
	print("Got level up signal")
	animate_level_change(old_level, new_level)

func _on_xp_ammount_changed(old_xp, new_xp):
	print("Got xp gained signal")
	var max_exp = Main.PLAYER.get_xp_for_next_level()
	BAR.max_value = max_exp
	animate_xp_change(old_xp, new_xp)

func _ready():
	pass
