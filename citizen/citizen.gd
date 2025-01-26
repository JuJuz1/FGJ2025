extends CharacterBody3D
class_name Citizen

@export_group("Citizen stats")
@export var speed: float = 3.5
@export_group("Health")
@export var max_health: int = 100
@export var current_health: int = max_health

signal damage_taken(latest_negative: bool)

enum Class {BAD, NEUTRAL, GOOD}
var citizen_class: Class

@onready var anim_player: AnimationPlayer = $character/AnimationPlayer
@onready var timer_idle: Timer = $Timer

@onready var label_health: Label3D = $LabelHealth

@onready var audio_stream_talk: AudioStreamPlayer3D = $AudioTalk
@onready var audio_stream_damage: AudioStreamPlayer3D = $AudioDamage

var speech_bubble_2: PackedScene = preload("res://citizen/speech_bubble_2.tscn")
var speech_bubble_3: PackedScene = preload("res://citizen/speech_bubble_3.tscn")
var speech_bubble_4: PackedScene = preload("res://citizen/speech_bubble_4.tscn")
var bubble
var current_emoji: EmojiData
var positive_opinion_forbidden: bool

var latest_emoji_negative: bool

var knockback: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_health_label()
	randomise_timer()
	var rand: float = randf_range(2.0, 14.0)
	await get_tree().create_timer(rand).timeout
	spawn_speech_bubble()


func update_health_label() -> void:
	label_health.text = "Health: " + str(current_health)


func take_damage(amount: int, direction: Vector3) -> void:
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "global_position:y", 1, 0.25).as_relative()
	tween.tween_property(self, "rotation:y", randf_range(-deg_to_rad(-80), deg_to_rad(80)), 0.5).as_relative()
	velocity = direction * 5.0
	current_health = clampi(current_health - amount, 0, max_health)
	update_health_label()
	audio_stream_damage.play()
	anim_player.play("Run")
	damage_taken.emit(latest_emoji_negative)
	if current_health == 0:
		await audio_stream_damage.finished
		queue_free()


func _on_timer_timeout() -> void:
	randomise_timer()


func _on_timer_knockback_timeout() -> void:
	if anim_player.current_animation == "run":
		anim_player.stop()


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
	#print_debug("Focused ", interactor.owner.name
	pass


func _on_interactable_interacted(interactor: Interactor) -> void:
	#print_debug("Interacted")
	pass


func _on_interactable_unfocused(interactor: Interactor) -> void:
	#print_debug("Unfocused ", interactor.owner.name)
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		#print_debug("Player entered ", name)
		pass


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		#print_debug("Player exited ", name)
		pass


func _physics_process(delta: float) -> void:
	if GameManager.freeze:
		return
	velocity.x = move_toward(velocity.x, 0, 5.0 * delta)
	velocity.z = move_toward(velocity.z, 0, 5.0 * delta)
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()


func _on_speech_bubble_timer_timeout():
	spawn_speech_bubble()

func spawn_speech_bubble():
	var rand_int = randi() % 3  # Random int 0, 1 or 2
	if rand_int == 0:
		bubble = speech_bubble_2.instantiate()
		add_child(bubble)
	elif rand_int == 1:
		bubble = speech_bubble_3.instantiate()
		add_child(bubble)
	else:
		bubble = speech_bubble_4.instantiate()
		add_child(bubble)
	
	var is_neutral_opinion: bool = randi() % 1000 < 200  # 20% chance to be true
	latest_emoji_negative = false
	match self.citizen_class:
		Class.BAD:
			if is_neutral_opinion: # Neutral speech bubble, 20% chance
				bubble.create_neutral(current_emoji)
			else: # 80% chance, forbidden speech bubble
				if positive_opinion_forbidden: # If positive opinion forbidden and bad, create positive opinion
					bubble.create_positive(current_emoji)
				else: # If negative opinion forbidden, create negative opinion
					bubble.create_negative(current_emoji)
					latest_emoji_negative = true
		Class.NEUTRAL:
			bubble.create_neutral(current_emoji) # Always neutral
		Class.GOOD:
			if is_neutral_opinion: # Neutral speech bubble, 20% chance
				bubble.create_neutral(current_emoji)
			else: # create good opinion, opposite of what is forbidden
				if positive_opinion_forbidden: # Create negative
					bubble.create_negative(current_emoji)
					latest_emoji_negative = true
				else: # If negative opinion forbidden, create positive
					bubble.create_positive(current_emoji)
