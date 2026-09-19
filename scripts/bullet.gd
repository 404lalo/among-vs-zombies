extends Node2D

var speed = 800
var direction = Vector2.RIGHT

func _process(delta):
	position += direction * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
