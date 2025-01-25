extends CanvasLayer
class_name GameUI

@onready var label_day_counter: Label = $LabelDayCounter
@onready var label_game_lose: Label = $LabelGameLose
@onready var label_game_win: Label = $LabelGameWin

@onready var label_time: Label = $BoxContainer/LabelTime

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_labels()
	label_time.text = ""


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


func update_time(time: int) -> void:
	var minutes: int = time / 60
	var seconds: int = time % 60
	label_time.text = str(minutes).lpad(2, "0") + ":" + str(seconds).lpad(2, "0")


func hide_time() -> void:
	label_time.hide()


func show_time() -> void:
	label_time.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
