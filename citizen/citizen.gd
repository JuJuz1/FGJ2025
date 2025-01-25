extends CharacterBody3D
class_name Citizen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
