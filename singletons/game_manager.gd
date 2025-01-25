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
var correct_punishes: int = 0
var total_punishes: int = 0
