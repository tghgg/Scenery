extends StaticBody2D

class_name NPC

onready var collider : CollisionShape2D = $BodyShape

func _on_VisibilityNotifier2D_screen_entered():
	visible = true
	collider.disabled = false

func _on_VisibilityNotifier2D_screen_exited():
	visible = false
	collider.disabled = true
