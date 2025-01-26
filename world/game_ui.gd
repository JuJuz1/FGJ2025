extends CanvasLayer
class_name GameUI

signal timer_start ## When we want to start the timer

@onready var label_day_counter: Label = $LabelDayCounter
@onready var label_game_lose: Label = $LabelGameLose
@onready var label_game_win: Label = $LabelGameWin
@onready var label_task: Label = $LabelTask

@onready var label_time: Label = $BoxContainer/LabelTime

@onready var label_awards: Label = $LabelAwards
@onready var label_wage: Label = $LabelWage

@onready var anim_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#hide_labels()
	pass


func hide_labels() -> void:
	for child in get_children():
		if child is Label:
			child.modulate.a = 0
	
	label_time.text = ""
	label_time.modulate.a = 0


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
		timer_start.emit()
		label_awards.modulate.a = 1
		label_wage.modulate.a = 1)


func show_label_lose() -> void:
	label_game_lose.show()


func update_time(time: int) -> void:
	var minutes: int = time / 60
	var seconds: int = time % 60
	label_time.text = str(minutes).lpad(2, "0") + ":" + str(seconds).lpad(2, "0")


func hide_time() -> void:
	label_time.hide()


func show_time() -> void:
	label_time.show()


func play_fade_in() -> void:
	GameManager.freeze = true
	anim_player.play("fade_in")


func play_fade_out() -> void:
	anim_player.play("fade_out")


func show_task(emoji: EmojiData, negative: bool) -> void:
	label_task.text = "Your task is to analyze citizens and watch their language.\n\n"
	if negative:
		label_task.text += "No one shall speak ill of " + emoji.string + "."
	else:
		label_task.text += "No one shall speak good of " + emoji.string + "."
	var tween: Tween = create_tween()
	tween.tween_interval(8)
	tween.tween_property(label_task, "modulate:a", 1, 0.5)
	tween.tween_interval(5)
	tween.tween_property(label_task, "modulate:a", 0, 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	label_awards.text = "Awards left: " + str(GameManager.awards_left)
	label_wage.text = "Total wage: " + str(GameManager.total_wage)
	print("Current: ", GameManager.current_wage)
	print("Total: ", GameManager.total_wage)
