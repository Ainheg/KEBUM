extends StaticBody

var opened = false
var is_looted = false
var is_hint = true
var player_level
var player_luck

signal hint_found

var item = null

func _ready():
	pass

func play_animation():
	if !opened:
		$AnimationPlayer.play("open_container")
		print(player_level)
		print(player_luck)
		var item_dict = Requests.request_item(player_level, player_luck, Items.get_new_item_seed())
		self.item = Items.Item.new(
			item_dict["name"],
			item_dict["rarity"],
			item_dict["type"],
			item_dict["stats"],
			item_dict["bonuses"]
		)
		opened = true

func init(x, y, z, hint):
	yield(self, "ready")
	self.is_hint = hint
	if self.is_hint:
		connect("hint_found", Main.BOSS, "uncover_hint")
	global_translate(Vector3(x, y, z))

func collect_item():
	PlayerInventory.add_item(item)
	is_looted = true

func update_popup():
	if is_hint:
		$ItemPickupDialog/VBoxContainer/Label.text = "You have found a hint!"
		$ItemPickupDialog/VBoxContainer/HBoxContainer/CenterContainer2/ItemStats.text = Main.BOSS.get_new_hint(Main.current_day - 1)
		return
	else:
		$ItemPickupDialog/VBoxContainer/Label.text = "You have found an item!"
	if item != null:
		$ItemPickupDialog/VBoxContainer/HBoxContainer/CenterContainer/ItemIcon.texture = Items.ITEM_TEXTURES[item.get_type()][item.get_rarity()]
		$ItemPickupDialog/VBoxContainer/HBoxContainer/CenterContainer2/ItemStats.text = item.get_tooltip()
	else:
		$ItemPickupDialog/VBoxContainer/HBoxContainer/CenterContainer/ItemIcon.texture = null
		$ItemPickupDialog/VBoxContainer/HBoxContainer/CenterContainer2/ItemStats.text = "Something happened..."

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
			if !is_looted:
				update_popup()
				$ItemPickupDialog.popup_centered()
				Main.show_mouse()

func _on_Proximity_body_exited(body):
	if !body.has_method("identify"):
		return
	match body.identify():
		"Player":
			if $ItemPickupDialog.visible:
				$ItemPickupDialog.hide()

func _on_ItemPickupDialog_confirmed():
	if !is_hint and item != null and PlayerInventory.can_add_item():
		collect_item()
	elif is_hint:
		is_looted = true
		emit_signal("hint_found")
	$ItemPickupDialog.hide()


func _on_ItemPickupDialog_popup_hide():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Main.hide_mouse()
	if is_hint:
		is_looted = true
		emit_signal("hint_found")
