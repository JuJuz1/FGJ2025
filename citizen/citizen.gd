extends Node3D
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
