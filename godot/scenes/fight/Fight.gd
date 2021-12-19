extends Node

onready var ENEMY_SPRITE = $UI/MarginC/VBC/HBC/EnemyContainer/Enemy
onready var PLAYER_SPRITE = $UI/MarginC/VBC/HBC/PlayerContainer/Player

onready var ENEMY_MOVES = $UI/MarginC/VBC/MovesUI/EnemyMoves.get_children()
onready var PLAYER_MOVES = $UI/MarginC/VBC/MovesUI/PlayerMoves.get_children()

onready var QUESTION_MARK_TXT = ImageTexture.new()
onready var ATTACK_TXT = ImageTexture.new()
onready var BLOCK_TXT = ImageTexture.new()
onready var PIERCE_TXT = ImageTexture.new()

onready var enemy_sequence = []
onready var player_sequence = []
onready var current_move_selection = 0
onready var turn = 1

signal fight_ended(winner)
signal moves_selected
var ENEMY
var PLAYER

var PLAYER_STATS
var ENEMY_STATS

func start_fight(enemy, player):
	ENEMY = enemy
	PLAYER = player
	ENEMY_STATS = enemy.get_stats()
	PLAYER_STATS = PlayerAttributes.get_stats()
	connect("moves_selected", self, "_process_moves")
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
	reset_moves()
	
func reset_moves():
	enemy_sequence = ENEMY.get_moves()
	player_sequence = []
	for icon in ENEMY_MOVES:
		icon.texture = QUESTION_MARK_TXT
	for icon in PLAYER_MOVES:
		icon.texture = QUESTION_MARK_TXT
	print("Enemy moves:")
	print(enemy_sequence)

func _increase_move_counter():
	current_move_selection += 1
	current_move_selection %= 3
	if current_move_selection == 0:
		turn += 1
		if turn == 3:
			turn = 1
			ENEMY.die()
			emit_signal("fight_ended", "player")
			print("Signal emited!")
		else:
			emit_signal("moves_selected")
	return

func _process_moves():
	reveal_enemy_moves()
	for i in range(3):
		var p_move = player_sequence[i]
		var e_move = enemy_sequence[i]
		
		print(p_move + " vs " + e_move)
		
		if p_move == e_move and p_move == "block":
			continue
		if p_move == e_move and p_move == "attack":
			attack(PLAYER, ENEMY, 1)
			attack(ENEMY, PLAYER, 1)
			continue
		if p_move == e_move and p_move == "pierce":
			attack(PLAYER, ENEMY, 1)
			attack(ENEMY, PLAYER, 1)
			continue
		if p_move == "attack" and e_move == "pierce":
			attack(PLAYER, ENEMY, 1.2)
			continue
		if p_move == "attack" and e_move == "block":
			attack(PLAYER, ENEMY, 0.1)
			attack(ENEMY, PLAYER, 1.3)
			continue
		if p_move == "block" and e_move == "pierce":
			attack(ENEMY, PLAYER, 1.2)
			continue
		if p_move == "block" and e_move == "attack":
			attack(ENEMY, PLAYER, 0.1)
			attack(PLAYER, ENEMY, 1.3)
			continue
		if p_move == "pierce" and e_move == "attack":
			attack(ENEMY, PLAYER, 1.2)
			continue
		if p_move == "pierce" and e_move == "block":
			attack(PLAYER, ENEMY, 1.2)
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
	
	pass

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
