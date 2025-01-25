extends Node3D

## Time
var current_time: int = 0
var starting_time: int = 10 ## TODO: change

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_time = starting_time
	player.global_position = player_spawn.global_position
	game_ui.show_label_day(current_day)
	game_ui.show_label_time(current_time)


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


## Change day
func change_day() -> void:
	current_day += 1
	if current_day == max_days:
		game_end()
	# TODO: transition, teleport player, prepare new day
	player.global_position = player_spawn.global_position
	current_time = starting_time
	timer_day.start()
	game_ui.show_time()


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


func game_end():
	# TODO:
	pass


func _on_game_ui_timer_start() -> void:
	timer_day.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
