extends CharacterBody3D
class_name Player

@export_group("Movement stats")
@export var speed: float =  25   #4.5
@export var sprint_speed: float = 7.5
@export var acceleration: float = 3.0
@export var jump_velocity: float = 5.0
@export_group("Combat")
@export var baton_damage: int = 40
@export_group("Mouse sensitivity")
@export var sensitivity: float = 4.0

const SENSITIVTY_DIVIDER: int = 100

signal awarded(negative: bool)
signal spawn_baton_hit_audio(audio: AudioStreamPlayer3D, position: Vector3)

const BATON_HIT = preload("res://player/baton_hit.tscn")

@onready var camera_holder: Node3D = $CameraHolder
@onready var interactor: Interactor = $CameraHolder/Interactor

@onready var hands_anim: AnimationPlayer = $hands/AnimationPlayer

@onready var label_fps: Label = $LabelFPS

@onready var audio_attack: AudioStreamPlayer3D = $AudioAttack
@onready var timer_audio_attack: Timer = $TimerAudioAttack

@onready var raycasts: Node3D = $Raycasts

var latest_damaged_body: Citizen
var awarded_citizens: Array[Citizen] = []


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Rotate the player character by y-axis (left and right)
		rotate_y(deg_to_rad(-event.screen_relative.x * sensitivity / SENSITIVTY_DIVIDER))
		# Rotates the camera holder around the x-axis (up and down)
		camera_holder.rotate_x(deg_to_rad(-event.screen_relative.y * sensitivity / SENSITIVTY_DIVIDER))
		# Clamp the rotation of the camera on the x-axis to prevent turning "over" the axis
		camera_holder.rotation.x = clampf(camera_holder.rotation.x, deg_to_rad(-87), deg_to_rad(87))


## Returns true if the current anim is not punch
func can_play_hands_anim() -> bool:
	return hands_anim.current_animation != "punch"


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "punch":
		latest_damaged_body = null


func _on_area_3d_baton_body_entered(body: Node3D) -> void:
	if body is Citizen and body != latest_damaged_body and not can_play_hands_anim():
		latest_damaged_body = body
		body.take_damage(baton_damage, global_position.direction_to(body.global_position))
		spawn_baton_hit_audio.emit(BATON_HIT, body.global_position)


func _on_area_3d_baton_body_exited(body: Node3D) -> void:
	if body is Citizen:
		pass


func _on_timer_audio_attack_timeout() -> void:
	audio_attack.play()


func any_raycast_collide() -> bool:
	for child: RayCast3D in raycasts.get_children():
		if child.is_colliding():
			return true
	return false


# Movement handling
func _physics_process(delta: float) -> void:
	if GameManager.freeze:
		return
	# Add the gravity.
	if not is_on_floor():
		# TODO: maybe just change project gravity
		velocity += get_gravity() * GameManager.gravity_modifier * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or any_raycast_collide():
			var original = velocity.y
			velocity.y = jump_velocity
			if velocity.y == original:
				global_position.y += 1.0
	
	if Input.is_action_just_pressed("attack") and can_play_hands_anim():
		hands_anim.play("punch")
		timer_audio_attack.start()
	
	if Input.is_action_just_pressed("award") and can_play_hands_anim() and hands_anim.current_animation != "awarding":
		if is_instance_valid(interactor.cached):
			if interactor.cached.owner is Citizen and GameManager.awards_left > 0:
				if interactor.cached.owner not in awarded_citizens:
					var citizen: Citizen = interactor.cached.owner
					hands_anim.play("awarding")
					awarded_citizens.append(citizen)
					GameManager.awards_left -= 1
					awarded.emit(citizen.latest_emoji_negative)
	
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var sprinting: bool = Input.is_action_pressed("sprint")
	var actual_speed: float = sprint_speed if sprinting else speed
	
	if direction:
		if can_play_hands_anim():
			if hands_anim.current_animation != "awarding":
				if sprinting:
					hands_anim.play("run", -1, 1.5)
				else:
					hands_anim.play("run")
		#if Input.is_action_just_pressed("sprint"):
		velocity.x = direction.x * actual_speed
		velocity.z = direction.z * actual_speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	if is_zero_approx(direction.length()) and can_play_hands_anim() and hands_anim.current_animation != "awarding":
		hands_anim.play("idle")
	
	#print("Velocity ", velocity.length())
	label_fps.text = "FPS: " + str(Engine.get_frames_per_second())
	
	# Small cooldown to moving when awarding
	if hands_anim.current_animation == "awarding":
		var length: float = hands_anim.current_animation_length - hands_anim.current_animation_position
		#print(length)
		if 1.2 < length:
			return
	
	move_and_slide()
