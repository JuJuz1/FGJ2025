extends Node3D
## World script

## Emojis
@export var all_emojis: EmojiDataArrays
var current_emoji: EmojiData
var current_emoji_negative: bool

## Time
var current_time: int = 0
var starting_time: int = 240 ## TODO: change 240?

## Day
var current_day: int = 1
var max_days: int = 5

## Citizens
var good_citizens_amount: int = 5
var bad_citizens_amount: int = 5
var max_citizens: int = 25

@onready var game_ui: GameUI = $GameUI

@onready var timer_day: Timer = $TimerDay

@onready var player: Player = $Player
@onready var player_spawn: Marker3D = $PlayerSpawn
@onready var player_spawn_direction: Marker3D = $PlayerSpawnDirection

@onready var citizens: Node3D = $Citizens
@onready var spawn_points: Node3D = $Citizens/SpawnPoints
const CITIZEN = preload("res://citizen/citizen.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODO: introduction
	
	current_time = starting_time
	player.global_position = player_spawn.global_position
	player.look_at(player_spawn_direction.global_position)
	game_ui.show_label_day(current_day)
	game_ui.show_label_time(current_time)
	game_ui.hide_labels()
	
	generate_task()
	create_citizens()


func create_citizens() -> void:
	for child in citizens.get_children():
		if child is Citizen:
			child.queue_free()
	
	var spawnpoints: Array = spawn_points.get_children()
	var spawn_coords: Array[Vector3]
	for spawnpoint: Marker3D in spawnpoints:
		spawn_coords.append(spawnpoint.global_position)
	spawn_coords.shuffle()
	
	var spawned: int = 0
	var bad_citizens_left: int = bad_citizens_amount
	var good_citizens_left: int = good_citizens_amount
	
	for coordinate: Vector3 in spawn_coords:
		var citizen: Citizen = CITIZEN.instantiate()
		if 0 < bad_citizens_left:
			citizen.citizen_class = citizen.Class.BAD
			bad_citizens_left -= 1
		elif 0 < good_citizens_left:
			citizen.citizen_class = citizen.Class.GOOD
			good_citizens_left -= 1
		else:
			citizen.citizen_class = citizen.Class.NEUTRAL
		citizen.positive_opinion_forbidden = not current_emoji_negative
		citizen.current_emoji = current_emoji
		citizen.damage_taken.connect(_on_citizen_damage_taken.bind())
		citizens.add_child(citizen)
		citizen.global_position = coordinate
		citizen.rotate_y(randf_range(deg_to_rad(-50), deg_to_rad(50)))
		spawned += 1
		if spawned == max_citizens:
			break


func generate_task() -> void:
	current_emoji = all_emojis.neutral_emoji_array.pick_random()
	var rand: float = randf_range(0, 1.0)
	if rand < 0.5:
		current_emoji_negative = true
	else:
		current_emoji_negative = false
	game_ui.show_task(current_emoji, current_emoji_negative)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		# PC escape
		if event.is_action_pressed("quit"):
			get_tree().quit()


func _on_timer_day_timeout() -> void:
	current_time -= 1
	game_ui.update_time(current_time)
	if current_time == 0:
		timer_day.stop()
		game_ui.hide_time()
		change_day()


## Change day
func change_day() -> void:
	current_day += 1
	if current_day == max_days:
		game_end()
	# TODO: transition, teleport player, prepare new day
	game_ui.play_fade_in()


func prepare_next_day() -> void:
	if GameManager.current_wage < GameManager.wage_threshhold:
		GameManager.missed_wage_thresholds += 1
		if GameManager.missed_wage_thresholds == GameManager.max_misses:
			game_end()
	
	GameManager.total_wage += GameManager.current_wage
	GameManager.current_wage = 0
	
	player.global_position = player_spawn.global_position
	player.look_at(player_spawn_direction.global_position)
	current_time = starting_time
	player.awarded_citizens.clear()
	GameManager.awards_left = 3
	game_ui.hide_labels()
	game_ui.show_label_day(current_day)
	game_ui.show_label_time(current_time)
	game_ui.play_fade_out()
	generate_task()
	create_citizens()


func start_day() -> void:
	GameManager.freeze = false
	game_ui.show_time()


func game_end():
	# TODO: win or lose
	if 2 <= GameManager.missed_wage_thresholds:
		game_ui.show_label_lose()
	else:
		game_ui.show_label_win()
	await get_tree().create_timer(5).timeout # TODO: signal
	get_tree().change_scene_to_file("res://world/start_menu.tscn")


func _on_game_ui_timer_start() -> void:
	#print("start")
	timer_day.start()


func _on_player_awarded(negative: bool) -> void:
	var success: bool = not (negative == current_emoji_negative)
	if success:
		GameManager.correct_awards += 1
		GameManager.current_wage += GameManager.award_wage_amount


func _on_citizen_damage_taken(negative_opinion: bool) -> void:
	var success: bool = negative_opinion == current_emoji_negative
	GameManager.total_punishes += 1
	if success:
		GameManager.correct_punishes += 1
		GameManager.current_wage += GameManager.punish_wage_amount


func _on_player_spawn_baton_hit_audio(audio_scene: PackedScene, hit_position: Vector3) -> void:
	var audio_hit: AudioStreamPlayer3D = audio_scene.instantiate()
	add_child(audio_hit)
	audio_hit.global_position = hit_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
