extends Node3D
## World script

## Emojis
@export var all_emojis: EmojiDataArrays
var current_emoji: Resource
var current_emoji_negative: bool

## Time
var current_time: int = 0
var starting_time: int = 15 ## TODO: change

## Day
var current_day: int = 1
var max_days: int = 5

## Wage
var current_wage: int = 0 ## Accumulated during the day
var total_wage: int = 0 ## Total
var wage_threshhold: int = 100 ## TODO change dynamically
var missed_wage_thresholds: int = 0 ## If the player misses the threshold -> increase
var max_misses: int = 3 ## If this reaches 0 -> the player loses

@onready var game_ui: GameUI = $GameUI

@onready var timer_day: Timer = $TimerDay

@onready var player: Player = $Player
@onready var player_spawn: Marker3D = $PlayerSpawn
#@onready var player_spawn_direction: Marker3D = $PlayerSpawnDirection

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODO: introduction
	
	current_time = starting_time
	player.global_position = player_spawn.global_position
	#player.look_at(player_spawn_direction.global_position)
	game_ui.show_label_day(current_day)
	game_ui.show_label_time(current_time)
	game_ui.hide_labels()
	
	generate_task()


func generate_task() -> void:
	current_emoji = all_emojis.neutral_emoji_array.pick_random()
	var rand: float = randf_range(0, 1.0)
	if rand < 0.5:
		current_emoji_negative = true
	else:
		current_emoji_negative = false
	game_ui.show_task(current_emoji, current_emoji_negative)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		# PC escape
		if event.is_action_pressed("quit"):
			get_tree().quit()


func _on_timer_day_timeout() -> void:
	current_time -= 1
	game_ui.update_time(current_time)
	if current_time == 0:
		timer_day.stop()
		game_ui.hide_time()
		change_day()


## Handle wage logic and start new day
func end_day() -> void:
	# Pause game and show the results of the day
	if current_wage < wage_threshhold:
		missed_wage_thresholds += 1
		if missed_wage_thresholds == max_misses:
			game_end()
	
	total_wage += current_wage
	current_wage = 0
	change_day()


## Change day
func change_day() -> void:
	current_day += 1
	if current_day == max_days:
		game_end()
	# TODO: transition, teleport player, prepare new day
	game_ui.play_fade_in()


func prepare_next_day() -> void:
	player.global_position = player_spawn.global_position
	#player.look_at(player_spawn_direction.global_position)
	current_time = starting_time
	game_ui.hide_labels()
	game_ui.show_label_day(current_day)
	game_ui.show_label_time(current_time)
	game_ui.play_fade_out()
	generate_task()

func start_day() -> void:
	GameManager.freeze = false
	game_ui.show_time()


func game_end():
	# TODO: win or lose
	game_ui.show_label_lose()
	await get_tree().create_timer(5).timeout # TODO: signal
	get_tree().reload_current_scene()


func _on_game_ui_timer_start() -> void:
	#print("start")
	timer_day.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
