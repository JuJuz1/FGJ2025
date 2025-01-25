class_name Interactable
extends Area3D
## Interactable component

## Owner node has to implement all these, otherwise deleted
signal focused(interactor: Interactor) ## Looking at the object
signal unfocused(interactor: Interactor) ## When looking away after was focused
signal interacted(interactor: Interactor) ## When interacted with

@export_group("Prompt")
@export var message: String = "Interact"
@export var alternative_message: String
@export var show_first: bool = true
@export_group("", "")
@export var can_interact: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not get_parent_node_3d() or (focused.get_connections().size() < 1
		or unfocused.get_connections().size() < 1 or interacted.get_connections().size() < 1):
		printerr("NO PARENT FOUND ON :", self, " ", self.name, " DELETING")
		printerr("OWNER ", owner.name)
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
