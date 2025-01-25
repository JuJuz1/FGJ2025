extends CanvasLayer
class_name GameUI

signal timer_start

@onready var label_day_counter: Label = $LabelDayCounter
@onready var label_game_lose: Label = $LabelGameLose
@onready var label_game_win: Label = $LabelGameWin

@onready var label_time: Label = $BoxContainer/LabelTime

@onready var anim_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_labels()
	label_time.text = ""
	label_time.modulate.a = 0


func hide_labels() -> void:
	for child in get_children():
		if child is Label:
			child.modulate.a = 0


func show_label_day(day: int) -> void:
	label_day_counter.text = "Day " + str(day)
	var tween: Tween = create_tween()
	tween.tween_interval(2)
	tween.tween_property(label_day_counter, "modulate:a", 1, 1)
	tween.tween_interval(3)
	tween.tween_property(label_day_counter, "modulate:a", 0, 1)


func show_label_time(time: int) -> void:
	update_time(time)
	var tween: Tween = create_tween()
	tween.tween_interval(4)
	tween.tween_property(label_time, "modulate:a", 1, 1)
	tween.tween_callback(func(): 
		timer_start.emit())


func update_time(time: int) -> void:
	var minutes: int = time / 60
	var seconds: int = time % 60
	label_time.text = str(minutes).lpad(2, "0") + ":" + str(seconds).lpad(2, "0")


func hide_time() -> void:
	label_time.hide()


func show_time() -> void:
	label_time.show()


func play_fade_in() -> void:
	anim_player.play("fade_in")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
