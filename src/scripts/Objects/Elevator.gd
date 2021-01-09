extends PairedExitPoint

onready var animation_player : AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: PhysicsBody2D) -> void:
	if body is Player and exit_scene:
		var current_root := get_tree().current_scene

		# Start an exit dialogue if specified
		if interaction_script:
			talk()
			yield(Global, "dialogue_finished")

		# Play the animation for the exit point
		animation_player.play("open")

		# Play the animation
		Global.get_player().freeze_movement()

		yield(animation_player,"animation_finished")

		Global.set_next_exit_point(current_root.filename, exit_scene, index)

		current_root.change_scene(exit_scene)
