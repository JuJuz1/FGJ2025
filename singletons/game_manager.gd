extends Node
## Game manager class
## handles the player's wage

## Day
var current_day: int = 0
var max_days: int = 5

## Wage
var current_wage: int = 0
var accumulated_wage: int = 0
var wage_threshhold: int = 100 # TODO change dynamically
var missed_wage_thresholds: int = 0 ## If the player misses the threshold -> increase
var max_misses: int = 3 ## If this reaches 0 -> the player loses

## Physics
var gravity_modifier: float = 1.25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func change_day() -> void:
	current_day += 1
	if current_day == max_days:
		game_end()
	# TODO: transition, teleport player, prepare new day


## Handle wage logic
func end_day() -> void:
	# Pause game and show the results of the day
	if current_wage < wage_threshhold:
		missed_wage_thresholds += 1
		if missed_wage_thresholds == max_misses:
			game_end()
	
	accumulated_wage += current_wage
	current_wage = 0
	change_day()


func game_end():
	# TODO:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
