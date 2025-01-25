extends CharacterBody3D
class_name Player

@export_group("Movement stats")
@export var speed: float = 4.5
@export var sprint_speed: float = 7.5
@export var acceleration: float = 3.0
@export var jump_velocity: float = 5.0
@export_group("Combat")
@export var baton_damage: int = 40
@export_group("Mouse sensitivity")
@export var sensitivity: float = 4.0

const SENSITIVTY_DIVIDER: int = 100

@onready var camera_holder: Node3D = $CameraHolder

@onready var hands_anim: AnimationPlayer = $hands/AnimationPlayer

@onready var label_fps: Label = $LabelFPS

var latest_damaged_body: Citizen

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


# Movement handling
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		# TODO: maybe just change project gravity
		velocity += get_gravity() * GameManager.gravity_modifier * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	if Input.is_action_just_pressed("attack") and can_play_hands_anim():
		hands_anim.play("punch")
	
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var sprinting: bool = Input.is_action_pressed("sprint")
	var actual_speed: float = sprint_speed if sprinting else speed
	
	if direction:
		if can_play_hands_anim():
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
	
	if is_zero_approx(direction.length()) and can_play_hands_anim():
		hands_anim.play("idle")
	
	#print("Velocity ", velocity.length())
	label_fps.text = "FPS: " + str(Engine.get_frames_per_second())
	
	move_and_slide()


func _on_area_3d_baton_body_entered(body: Node3D) -> void:
	if body is Citizen and body != latest_damaged_body and not can_play_hands_anim():
		print("Ez")
		latest_damaged_body = body
		body.take_damage(baton_damage)


func _on_area_3d_baton_body_exited(body: Node3D) -> void:
	if body is Citizen:
		pass
