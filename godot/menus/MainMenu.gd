extends Control

func _ready():
	pass

func _on_NewGame_pressed():
	Main.new_dungeon()


func _on_Seed_text_changed(new_text):
	Main._seed = int(new_text)
