extends Control

func _ready():
	pass

func _on_NewGame_pressed():
	Main.new_game()


func _on_Seed_text_changed(new_text):
	Main.game_seed = int(new_text)
