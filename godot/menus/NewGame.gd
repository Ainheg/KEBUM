extends Button

func _on_NewGame_pressed():
	var dng = load("res://scenes/dungeon/Dungeon.tscn").instance()
	var map_dict = Requests.request_map("cave", 123)
	get_tree().root.add_child(dng)
	dng.init(map_dict)
	print(get_tree().change_scene_to(dng))
