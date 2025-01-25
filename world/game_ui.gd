extends CanvasLayer
class_name GameUI

@onready var label_day_counter: Label = $LabelDayCounter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_labels()


func hide_labels() -> void:
	for child in get_children():
		if child is Label:
			child.modulate.a = 0


func show_label_day() -> void:
	var tween: Tween = create_tween()
	tween.tween_interval(2)
	tween.tween_property(label_day_counter, "modulate:a", 1, 1)
	tween.tween_interval(3)
	tween.tween_property(label_day_counter, "modulate:a", 0, 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
