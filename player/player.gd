extends CharacterBody3D
class_name Player

@export_group("Movement stats")
@export var speed: float = 4.5
@export var sprint_speed: float = 7.0
@export var acceleration: float = 3.0
@export var jump_velocity: float = 5.0
@export_group("Mouse sensitivity")
@export var sensitivity: float = 4.0 / 100

@onready var camera_holder: Node3D = $CameraHolder

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Rotate the player character by y-axis (left and right)
		rotate_y(deg_to_rad(-event.screen_relative.x * sensitivity))
		# Rotates the camera holder around the x-axis (up and down)
		camera_holder.rotate_x(deg_to_rad(-event.screen_relative.y * sensitivity))
		# Clamp the rotation of the camera on the x-axis to prevent turning "over" the axis
		camera_holder.rotation.x = clampf(camera_holder.rotation.x, deg_to_rad(-87), deg_to_rad(87))


# Movement handling
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		# TODO: maybe just change project gravity
		velocity += get_gravity() * GameManager.gravity_modifier * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	if Input.is_action_just_pressed("attack"):
		print("attack")
		# TODO: anim_player
	
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var actual_speed: float = sprint_speed if Input.is_action_pressed("sprint") else speed
	
	if direction:
		velocity.x = direction.x * actual_speed
		velocity.z = direction.z * actual_speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	#print("Velocity ", velocity.length())
	
	move_and_slide()
