extends Node


func _ready():
	Main.bind_root(get_parent())
	Main.show_menu()
