extends CharacterBody3D
class_name Citizen

@onready var anim_player: AnimationPlayer = $character/AnimationPlayer
@onready var timer_idle: Timer = $Timer

@onready var label_3d: Label3D = $Label3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_3d.text = name
	randomise_timer()


func _on_timer_timeout() -> void:
	randomise_timer()


func randomise_timer() -> void:
	var random: float = randf_range(0, 1.0)
	print_debug("Timeout ", name, " Random: ", random)
	# Some simple logic to stop idle with 50% change if it is playing
	if anim_player.current_animation == "idle" and random < 0.5:
		anim_player.stop()
	else:
		anim_player.play("idle")
	timer_idle.wait_time = randf_range(2.0, 10.0)
	timer_idle.start()


func _on_interactable_focused(interactor: Interactor) -> void:
	# TODO: outline shader
	print_debug("Focused ", interactor.owner.name)


func _on_interactable_interacted(interactor: Interactor) -> void:
	#print_debug("Interacted")
	pass


func _on_interactable_unfocused(interactor: Interactor) -> void:
	print_debug("Unfocused ", interactor.owner.name)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * GameManager.gravity_modifier * delta
	else:
		velocity = Vector3.ZERO
	
	move_and_slide()
