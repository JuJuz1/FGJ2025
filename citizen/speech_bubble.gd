extends Node3D

var player
var children
const DESPAWN_DELAY = 15  # How many seconds before speech bubble disappears

@onready var despawn_timer: Timer = $DespawnTimer

@export var all_emojis: Resource

func _ready():
	self.set_scale(Vector3(0, 0, 0))
	rotation.y = self.rotation.y + PI
	player = get_node("/root/World/Player")
	children = self.get_children()
	despawn_timer.wait_time = DESPAWN_DELAY


func _process(_delta):
	var position = player.position
	self.look_at(position, Vector3.UP, true)


func get_random_neutral_emoji() -> EmojiData:
	return all_emojis.neutral_emoji_array[randi() % 39]

func get_random_neutral_emoji_except(emoji: EmojiData):
	var rand_emoji: EmojiData
	while true:
		rand_emoji = get_random_neutral_emoji()
		if (rand_emoji != EmojiData):
			break
	return rand_emoji

func get_random_negative_emoji()-> EmojiData:
	return all_emojis.negative_emoji_array[randi() % 9]

func get_random_positive_emoji()-> EmojiData:
	return all_emojis.positive_emoji_array[randi() % 9]


# Creates speech bubble beginning with a negative emoji and containing 'topic'
func create_negative(topic: EmojiData):
	children[1].set_texture(get_random_negative_emoji().svg) # Set first emoji to a random negative emoji
	var emoji_count: int = self.get_child_count() - 1
	match emoji_count:
		2:
			children[2].set_texture(topic.svg) # Set 'topic' emoji
		3:
			var topic_index: int = (randi() % 2 + 2)
			var neutral_emoji: EmojiData = get_random_neutral_emoji()
			if (topic_index == 2):
				children[2].set_texture(topic.svg)
				children[3].set_texture(neutral_emoji.svg)
			else:
				children[3].set_texture(topic.svg)
				children[2].set_texture(neutral_emoji.svg)
		4:
			var neutral_emoji1 = get_random_neutral_emoji()
			var neutral_emoji2 = get_random_neutral_emoji()
			var topic_index = (randi() % 3 + 2)
			children[topic_index].set_texture(topic.svg)
			if (topic_index == 2):
				children[3].set_texture(neutral_emoji1.svg)
				children[4].set_texture(neutral_emoji2.svg)
			elif (topic_index == 3):
				children[2].set_texture(neutral_emoji1.svg)
				children[4].set_texture(neutral_emoji2.svg)
			elif (topic_index == 4):
				children[2].set_texture(neutral_emoji1.svg)
				children[3].set_texture(neutral_emoji2.svg)
		_:
			printerr("Amount of emojis in a speech bubble is less than 2 or more than 4! This should not happen!")
	appear()


# Creates speech bubble with random emojis, except the topic emoji
func create_neutral(topic: EmojiData):
	if (randi() % 2 == 0):
		children[1].set_texture(get_random_negative_emoji().svg) # Set first emoji to a random negative emoji
	else:
		children[1].set_texture(get_random_positive_emoji().svg) # Set first emoji to a random positive emoji
	var emoji_count: int = self.get_child_count() - 1
	match emoji_count:
		2:
			children[2].set_texture(get_random_neutral_emoji_except(topic).svg)
		3:
			children[2].set_texture(get_random_neutral_emoji_except(topic).svg)
			children[3].set_texture(get_random_neutral_emoji_except(topic).svg)
		4:
			children[2].set_texture(get_random_neutral_emoji_except(topic).svg)
			children[3].set_texture(get_random_neutral_emoji_except(topic).svg)
			children[4].set_texture(get_random_neutral_emoji_except(topic).svg)
	appear()


# Creates speech bubble beginning with a positive emoji and containing 'topic'
func create_positive(topic: EmojiData):
	children[1].set_texture(get_random_positive_emoji().svg) # Set first emoji to a random positive emoji
	var emoji_count: int = self.get_child_count() - 1
	match emoji_count:
		2:
			children[2].set_texture(topic.svg) # Set 'topic' emoji
		3:
			var topic_index: int = (randi() % 2 + 2)
			var neutral_emoji: EmojiData = get_random_neutral_emoji()
			if (topic_index == 2):
				children[2].set_texture(topic.svg)
				children[3].set_texture(neutral_emoji.svg)
			else:
				children[3].set_texture(topic.svg)
				children[2].set_texture(neutral_emoji.svg)
		4:
			var neutral_emoji1 = get_random_neutral_emoji()
			var neutral_emoji2 = get_random_neutral_emoji()
			var topic_index = (randi() % 3 + 2)
			children[topic_index].set_texture(topic.svg)
			if (topic_index == 2):
				children[3].set_texture(neutral_emoji1.svg)
				children[4].set_texture(neutral_emoji2.svg)
			elif (topic_index == 3):
				children[2].set_texture(neutral_emoji1.svg)
				children[4].set_texture(neutral_emoji2.svg)
			elif (topic_index == 4):
				children[2].set_texture(neutral_emoji1.svg)
				children[3].set_texture(neutral_emoji2.svg)
		_:
			printerr("Amount of emojis in a speech bubble is less than 2 or more than 4! This should not happen!")
	appear()


func appear():
	var tween = self.create_tween()
	tween.tween_property(self, "scale", Vector3(0.2, 0.2, 0.2), 1)
	despawn_timer.start()


func _on_despawn_timer_timeout():
	var tween = self.create_tween().parallel()
	tween.tween_property(self, "position:y", 4, 3).as_relative()
	tween.tween_property(self, "modulate:a", 0, 3)
	tween.tween_callback(func(): queue_free())
