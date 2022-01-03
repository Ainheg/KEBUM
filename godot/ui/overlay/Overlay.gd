extends Control

onready var CHARACTER_WINDOW = $Margin/CenterContainer/Inventory
signal character_window_opened

func init():
	$Margin/XPCounter.init()
	self.connect("character_window_opened", CHARACTER_WINDOW, "_on_show")
	CHARACTER_WINDOW.visible = false

func reset():
	$Margin/XPCounter.init()

func _physics_process(_delta):
	if !is_visible_in_tree():
		return
	if Input.is_action_just_released("open_character_window"):
		CHARACTER_WINDOW.visible = !CHARACTER_WINDOW.visible
		if CHARACTER_WINDOW.visible:
			emit_signal("character_window_opened")
			Main.show_mouse()
			print("Character window opened!")
		else:
			Main.hide_mouse()

func _ready():
	pass
