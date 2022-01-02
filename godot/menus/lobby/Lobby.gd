extends Control

var initialized = false

onready var ROUND_LABEL = $HBoxContainer/GameContainer/RoundLabel
onready var DAY_LABEL = $HBoxContainer/GameContainer/DayLabel
onready var DUNGEON_TYPE_LABEL = $HBoxContainer/GameContainer/DungeonContainer/DungeonVBoxContainer/DungeonType
onready var DUNGEON_SEED_INPUT = $HBoxContainer/GameContainer/DungeonContainer/DungeonVBoxContainer/Seed
onready var ENEMY_LEVEL_LABEL = $HBoxContainer/EnemyInfoContainer/EnemyLevel
onready var ENEMY_NAME_LABEL = $HBoxContainer/EnemyInfoContainer/EnemyName
onready var INFO_1_LABEL = $HBoxContainer/EnemyInfoContainer/InfoContainer/Info1/Label
onready var INFO_2_LABEL = $HBoxContainer/EnemyInfoContainer/InfoContainer/Info2/Label
onready var INFO_3_LABEL = $HBoxContainer/EnemyInfoContainer/InfoContainer/Info3/Label

func _ready():
	print("Hello world!")
	initialized = true
	call_deferred("refresh")

func _enter_tree():
	if !initialized:
		return
	refresh()

func _on_Seed_text_changed(new_text):
	print("New seed: " + str(new_text))
	Main.dungeon_seed = new_text
	print(str(Main.dungeon_seed))

func _on_EnterBtn_pressed():
	if !Main.is_bossfight_day():
		Main.new_dungeon()
	else:
		Main.initiate_fight(Main.BOSS)

func refresh():
	print("Refreshing lobby")
	ROUND_LABEL.text = "Round " + str(Main.current_round) + "/" + str(Main.MAX_ROUNDS)
	
	if Main.is_bossfight_day():
		DAY_LABEL.text = "Final day of the round"
	
	DAY_LABEL.text = "Day " + str(Main.current_day) + "/" + str(Main.MAX_DAYS)
	DUNGEON_TYPE_LABEL.text = "Dungeon type: " + str(Main.get_next_dungeon_type())
	DUNGEON_SEED_INPUT.text = str(Main.dungeon_seed)
	
	ENEMY_NAME_LABEL.text = str(Main.BOSS.get_name())
	ENEMY_LEVEL_LABEL.text = "Level " + str(Main.BOSS.get_level())
	
	INFO_1_LABEL.text = Main.BOSS.get_hint(0)
	INFO_2_LABEL.text = Main.BOSS.get_hint(1)
	INFO_3_LABEL.text = Main.BOSS.get_hint(2)
