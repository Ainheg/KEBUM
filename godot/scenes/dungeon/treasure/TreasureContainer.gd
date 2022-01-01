extends StaticBody

var opened = false
var is_looted = false
var is_hint = true
var player_level
var player_luck

var item = PlayerInventory.Item.new("Zwykły Kij",
			 "Common",
			 "Weapon",
			 {"STR" : 1, "AGI" : 0, "PER" : 0, "DEF" : 0, "LCK" : 0, "CST" : 0},
			 {})

func _ready():
	pass

func play_animation():
	if !opened:
		$AnimationPlayer.play("open_container")
		print(player_level)
		print(player_luck)
		#self.item = Requests.get_item(player_level, player_luck)
		opened = true

func init(x, y, z, is_hint):
	yield(self, "ready")
	self.is_hint = is_hint
	global_translate(Vector3(x, y, z))

func collect_item():
	PlayerInventory.add_item(item)
	is_looted = true

func update_popup():
	if is_hint:
		print("Hint znalezion")
		$ItemPickupDialog/VBoxContainer/Label.text = "You have found a hint!"
		return
	else:
		$ItemPickupDialog/VBoxContainer/Label.text = "You have found an item!"
	if item != null:
		$ItemPickupDialog/VBoxContainer/HBoxContainer/CenterContainer/ItemIcon.texture = PlayerInventory.ITEM_TEXTURES[item.get_type()][item.get_rarity()]
		$ItemPickupDialog/VBoxContainer/HBoxContainer/CenterContainer2/ItemStats.text = item.get_tooltip()
	else:
		$ItemPickupDialog/VBoxContainer/HBoxContainer/CenterContainer/ItemIcon.texture = null
		$ItemPickupDialog/VBoxContainer/HBoxContainer/CenterContainer2/ItemStats.text = "Ooops, you didn't"

func identify():
	return "TreasureContainer"

func _on_Proximity_body_entered(body):
	if !body.has_method("identify"):
		return
	match body.identify():
		"Player":
			print("Player entered")
			if !opened:
				player_level = body.get_level()
				player_luck = body.get_stats_with_items()["LCK"]
				play_animation()
				yield($AnimationPlayer, "animation_finished")
			if !is_looted:
				print("Jest itemek do zebrania")
				update_popup()
				$ItemPickupDialog.popup_centered()
				Main.show_mouse()
			print("Nie ma itemka do zebrania")

func _on_Proximity_body_exited(body):
	if !body.has_method("identify"):
		return
	match body.identify():
		"Player":
			print("Player left")
			if $ItemPickupDialog.visible:
				$ItemPickupDialog.hide()
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
				Main.hide_mouse()

func _on_ItemPickupDialog_confirmed():
	if !is_hint and item != null and PlayerInventory.can_add_item():
		collect_item()
	elif is_hint:
		is_looted = true
	$ItemPickupDialog.hide()
