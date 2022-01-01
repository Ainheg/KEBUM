extends Node

onready var ENEMY_SPRITE = $UI/MarginC/VBC/HBC/EnemyContainer/VBC/Enemy
onready var PLAYER_SPRITE = $UI/MarginC/VBC/HBC/PlayerContainer/VBC/Player

onready var ENEMY_MOVES = $UI/MarginC/VBC/MovesUI/EnemyMoves.get_children()
onready var PLAYER_MOVES = $UI/MarginC/VBC/MovesUI/PlayerMoves.get_children()

onready var PLAYER_HP_BAR = $UI/MarginC/VBC/HBC/PlayerContainer/VBC/PlayerHPBar
onready var ENEMY_HP_BAR = $UI/MarginC/VBC/HBC/EnemyContainer/VBC/EnemyHPBar

onready var QUESTION_MARK_TXT = ImageTexture.new()
onready var ATTACK_TXT = ImageTexture.new()
onready var BLOCK_TXT = ImageTexture.new()
onready var PIERCE_TXT = ImageTexture.new()

onready var rng = RandomNumberGenerator.new()
onready var enemy_sequence = []
onready var player_sequence = []
onready var current_move_selection = 0

signal fight_ended(winner)
signal moves_selected

var ENEMY
var PLAYER
var MOVES_TXT
var fight_ended = false
var first_start = true

func start_fight(enemy, player):
	if first_start:
		yield(self, "ready")
		connect("moves_selected", self, "_process_moves")
		first_start = false
	print(enemy)
	self.ENEMY = enemy
	self.PLAYER = player
	print("Enemy type: " + enemy.type)
	ENEMY.connect("enemy_died", self, "_enemy_died")
	if !PLAYER.is_connected("player_died", self, "_player_died"):
		PLAYER.connect("player_died", self, "_player_died")
	if !PLAYER.is_connected("health_changed", PLAYER_HP_BAR, "_on_health_changed"):
		PLAYER.connect("health_changed", PLAYER_HP_BAR, "_on_health_changed")
	ENEMY.connect("health_changed", ENEMY_HP_BAR, "_on_health_changed")
	PLAYER_HP_BAR.init(PLAYER.get_current_health(), PLAYER.get_max_health())
	ENEMY_HP_BAR.init(ENEMY.get_current_health(), ENEMY.get_max_health())
	#PLAYER_HP_BAR.call_deferred("init", PLAYER.get_current_health(), PLAYER.get_max_health())
	#ENEMY_HP_BAR.call_deferred("init", ENEMY.get_current_health(), ENEMY.get_max_health())
	rng.randomize()
	reset_moves()
	print("Fight started")

func _ready():
	## LOADING IMAGES FOR MOVE TEXTURES ##
	var img = Image.new()
	if img.load("res://scenes/fight/assets/question_mark_icon.png") != OK:
		print("Couldn't load question mark icon texture")
	QUESTION_MARK_TXT.create_from_image(img)
	if img.load("res://scenes/fight/assets/attack_icon.png") != OK:
		print("Couldn't load attack icon texture")
	ATTACK_TXT.create_from_image(img)
	if img.load("res://scenes/fight/assets/block_icon.png") != OK:
		print("Couldn't load block icon texture")
	BLOCK_TXT.create_from_image(img)
	if img.load("res://scenes/fight/assets/pierce_icon.png") != OK:
		print("Couldn't load pierce icon texture")
	PIERCE_TXT.create_from_image(img)
	MOVES_TXT = {
		"attack" : ATTACK_TXT,
		"block" : BLOCK_TXT,
		"pierce" : PIERCE_TXT
	}
	
func reset_moves():
	fight_ended = false
	enemy_sequence = self.ENEMY.get_moves()
	player_sequence = []
	for icon in ENEMY_MOVES:
		icon.texture = QUESTION_MARK_TXT
	for icon in PLAYER_MOVES:
		icon.texture = QUESTION_MARK_TXT
	if rng.randf() <= PLAYER.get_derived_stats()["REV_CHANCE"]:
		print("Move revealed")
		var slot = rng.randi() % 3
		ENEMY_MOVES[slot].texture = MOVES_TXT[enemy_sequence[slot]]
	print("Enemy moves:")
	print(enemy_sequence)

func _increase_move_counter():
	current_move_selection += 1
	current_move_selection %= 3
	if current_move_selection == 0:
		emit_signal("moves_selected")
	return

func _process_moves():
	reveal_enemy_moves()
	for i in range(3):
		if fight_ended:
			break
		var p_move = player_sequence[i]
		var e_move = enemy_sequence[i]
		
		print(p_move + " vs " + e_move)
		
		if p_move == e_move and p_move == "block":
			continue
		if p_move == e_move and p_move == "attack":
			attack(PLAYER, self.ENEMY, 1)
			attack(self.ENEMY, PLAYER, 1)
			continue
		if p_move == e_move and p_move == "pierce":
			attack(PLAYER, self.ENEMY, 1)
			attack(self.ENEMY, PLAYER, 1)
			continue
		if p_move == "attack" and e_move == "pierce":
			attack(PLAYER, self.ENEMY, 1.2)
			continue
		if p_move == "attack" and e_move == "block":
			attack(PLAYER, self.ENEMY, 0.1)
			attack(self.ENEMY, PLAYER, 1.3)
			continue
		if p_move == "block" and e_move == "pierce":
			attack(self.ENEMY, PLAYER, 1.2)
			continue
		if p_move == "block" and e_move == "attack":
			attack(self.ENEMY, PLAYER, 0.1)
			attack(PLAYER, self.ENEMY, 1.3)
			continue
		if p_move == "pierce" and e_move == "attack":
			attack(self.ENEMY, PLAYER, 1.2)
			continue
		if p_move == "pierce" and e_move == "block":
			attack(PLAYER, self.ENEMY, 1.2)
			continue
	reset_moves()

func reveal_enemy_moves():
	for i in range(3):
		match(enemy_sequence[i]):
			"attack":
				ENEMY_MOVES[i].texture = ATTACK_TXT
			"block":
				ENEMY_MOVES[i].texture = BLOCK_TXT
			"pierce":
				ENEMY_MOVES[i].texture = PIERCE_TXT

func attack(attacker, defender, dmg_mulitplier):
	rng.randomize()
	var dmg_dealt = 0.0
	
	var attacker_stats = attacker.get_derived_stats()
	var defender_stats = defender.get_derived_stats()
	
	dmg_dealt += 0.25 * attacker_stats["ATK_PWR"]
	dmg_dealt += attacker_stats["ATK_PWR"] / defender_stats["ARMOR"]
	
	dmg_dealt *= dmg_mulitplier
	
	# Crit chance
	if rng.randf() <= attacker_stats["CRIT_CHANCE"]:
		print("Crit")
		dmg_dealt *= attacker_stats["CRIT_DMG"]
	
	# Accuracy chance
	print("Accuracy: " + str(attacker_stats["ACCURACY"]))
	print(rng.randf())
	if rng.randf() >= attacker_stats["ACCURACY"]:
		print("Miss")
		dmg_dealt = 0
	
	# Evade chance
	if rng.randf() <= defender_stats["EVA_CHANCE"]:
		print("Evade")
		dmg_dealt = 0
	
	defender.add_health(-dmg_dealt)
	attacker.add_health(attacker_stats["LIFESTEAL"] * dmg_dealt)

func _player_died():
	print("You died")
	fight_ended = true
	emit_signal("fight_ended", "enemy")

func _enemy_died():
	print("Enemy died")
	fight_ended = true
	ENEMY.die()
	var xp_gained = 10 + PLAYER.get_xp_for_next_level() / 10
	xp_gained = rng.randi_range(int(xp_gained * 0.8), int(xp_gained * 1.2))
	PLAYER.add_xp(xp_gained)
	PLAYER.restore_health()
	emit_signal("fight_ended", "player")

func _on_AtkBtn_pressed():
	PLAYER_MOVES[current_move_selection].texture = ATTACK_TXT
	player_sequence.append("attack")
	_increase_move_counter()
	
func _on_BlkBtn_pressed():
	PLAYER_MOVES[current_move_selection].texture = BLOCK_TXT
	player_sequence.append("block")
	_increase_move_counter()

func _on_PrcBtn_pressed():
	PLAYER_MOVES[current_move_selection].texture = PIERCE_TXT
	player_sequence.append("pierce")
	_increase_move_counter()
