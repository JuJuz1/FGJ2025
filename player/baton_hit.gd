extends AudioStreamPlayer3D
## Self-destructing AudioStreamPlayer3D for baton hit

func _ready() -> void:
	play()


func _on_finished() -> void:
	queue_free()
