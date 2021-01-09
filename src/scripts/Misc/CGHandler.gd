extends Node2D

class_name CgHandler

onready var tween_fade_out : Tween = $FadeOut
onready var tween_fade_in : Tween = $FadeIn
onready var camera : Camera2D = $Camera2D

func fade_out(time := 2.5, cg := "BG") -> void:
	tween_fade_out.interpolate_property(get_node(cg), "modulate:a", 1.0, 0.0, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween_fade_out.start()
	yield(tween_fade_out, "tween_completed")
	Global.get_player().camera.make_current()


func fade_in(time := 2.5, cg := "BG") -> void:
	if not get_node(cg).is_visible(): get_node(cg).set_visible(true)

	# Snap the camera to the CG area
	camera.make_current()

	# Fade in CG
	get_node(cg).z_index = 50
	get_node(cg).z_as_relative = true
	get_node(cg).set_visible(true)

	tween_fade_in.interpolate_property(get_node(cg), "modulate:a", 0.0, 1.0, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween_fade_in.start()
