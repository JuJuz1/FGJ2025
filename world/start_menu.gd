extends Node3D
## Start menu

@onready var credits_screen: Control = $CreditsScreen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	credits_screen.hide()
	if not GameManager.start_from_start_screen:
		start_game()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit") and credits_screen.visible:
		credits_screen.hide()


func _on_button_start_pressed() -> void:
	start_game()


func _on_button_credits_pressed() -> void:
	credits_screen.show()


func _on_button_quit_pressed() -> void:
	get_tree().quit()


func start_game() -> void:
	get_tree().change_scene_to_file("res://world/world.tscn")


func _physics_process(delta: float) -> void:
	$Camera3D.rotate_y(delta * -0.5)
