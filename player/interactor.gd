extends Node3D
class_name Interactor

@export var label_punish_color: Color
@export var label_commend_color: Color

@onready var ray_cast: RayCast3D = $RayCast3D
@onready var labels: HBoxContainer = $Labels

@onready var v_box_container_punish: VBoxContainer = $Labels/VBoxContainerPunish
@onready var v_box_container_commend: VBoxContainer = $Labels/VBoxContainerCommend

## Save the latest interactable
var cached: Interactable

func _ready() -> void:
	set_label_colors()
	labels.hide()


func set_label_colors() -> void:
	for child: Label in v_box_container_punish.get_children():
		child.modulate = label_punish_color
	
	for child: Label in v_box_container_commend.get_children():
		child.modulate = label_commend_color


func focus(interactable: Interactable) -> void:
	labels.show()
	interactable.focused.emit(self)


func unfocus(interactable: Interactable) -> void:
	interactable.unfocused.emit(self)
	labels.hide()


func interact(interactable: Interactable) -> void:
	interactable.interacted.emit(self)


func _physics_process(_delta: float) -> void:
	if ray_cast.is_colliding():
		var collider: Object = ray_cast.get_collider()
		if collider is Interactable:
			if not collider == cached:
				if collider.can_interact:
					if is_instance_valid(cached):
						unfocus(cached)
					if collider:
						focus(collider)
					cached = collider
			else:
				if is_instance_valid(cached):
					if not cached.can_interact:
						unfocus(cached)
						cached = null
		else:
			if is_instance_valid(cached):
				unfocus(cached)
				cached = null
	else:
		if is_instance_valid(cached):
			unfocus(cached)
			cached = null
		else:
			labels.hide()
