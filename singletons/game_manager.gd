extends Node
## Game manager class

## A bool to determine wheter to start the game immediately
var start_from_start_screen: bool = true

## Freezes some game processes, mainly used for day transition
var freeze: bool = false

## Physics
var gravity_modifier: float = 1.25

## Awards and punishes
var awards_left: int = 3
var correct_awards: int = 0
var total_punishes: int = 0
var correct_punishes: int = 0

## Wage
var current_wage: int = 0 ## Accumulated during the day
var total_wage: int = 0 ## Total
var wage_threshhold: int = 100 ## TODO change dynamically
var missed_wage_thresholds: int = 0 ## If the player misses the threshold -> increase
var max_misses: int = 3 ## If this reaches 0 -> the player loses
