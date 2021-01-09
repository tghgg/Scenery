extends VisibilityEnabler2D

func _on_VisibilityEnabler2D_screen_entered():
	get_parent().visible = true

func _on_VisibilityEnabler2D_screen_exited():
	get_parent().visible = false
