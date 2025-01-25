extends Node3D

var player

func _ready():
	self.set_scale(Vector3(0.2, 0.2, 0.2))
	rotation.y = self.rotation.y + PI
	player = get_node("/root/World/Player")

func _process(_delta):
	var position = player.position
	self.look_at(position, Vector3.UP, true)
