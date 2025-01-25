extends Node3D

@onready var game_ui: CanvasLayer = $GameUI

@onready var player: Player = $Player
@onready var player_spawn: Marker3D = $PlayerSpawn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_ui.show_label_day()
	player.global_position = player_spawn.global_position


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		# PC escape
		if event.is_action_pressed("quit"):
			get_tree().quit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
