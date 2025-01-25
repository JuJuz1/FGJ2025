extends CharacterBody3D
class_name Citizen

@export_group("Citizen stats")
@export var speed: float = 3.5
@export_group("Health")
@export var max_health: int = 100
@export var current_health: int = max_health

@onready var anim_player: AnimationPlayer = $character/AnimationPlayer
@onready var timer_idle: Timer = $Timer

@onready var label_3d: Label3D = $Label3D
@onready var label_health: Label3D = $LabelHealth

@onready var audio_stream_talk: AudioStreamPlayer3D = $AudioTalk
@onready var audio_stream_damage: AudioStreamPlayer3D = $AudioDamage

var knockback: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_3d.text = name
	update_health_label()
	randomise_timer()


func update_health_label() -> void:
	label_health.text = "Health: " + str(current_health)


func take_damage(amount: int, direction: Vector3) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position:y", 1, 0.25).as_relative()
	velocity = direction * 5.0
	# TODO: show visually, logic
	current_health = clampi(current_health - amount, 0, max_health)
	update_health_label()
	audio_stream_damage.play()
	if current_health == 0:
		queue_free()


func _on_timer_timeout() -> void:
	randomise_timer()


func randomise_timer() -> void:
	var random: float = randf_range(0, 1.0)
	#print_debug("Timeout ", name, " Random: ", random)
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


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		print_debug("Player entered ", name)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		print_debug("Player exited ", name)


func _physics_process(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 5.0 * delta)
	velocity.z = move_toward(velocity.z, 0, 5.0 * delta)
	if not is_on_floor():
		velocity += get_gravity() * GameManager.gravity_modifier * delta
	
	move_and_slide()
