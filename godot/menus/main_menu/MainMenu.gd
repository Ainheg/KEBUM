extends Control

func _ready():
	$CenterContainer/VBoxContainer/Seed.text = str(Main.game_seed)

func _on_NewGame_pressed():
	Main.new_game()

func _on_Seed_text_changed(new_text):
	Main.game_seed = new_text
