extends Node2D

class_name Transitioner

onready var tween_fade_out : Tween = $FadeOut
onready var tween_fade_in : Tween = $FadeIn

onready var black_screen : Sprite = $BlackScreen

onready var silhoulette : Sprite = $Silhoulette


func _ready() -> void:
	black_screen.visible = true


# Fade out a child sprite
func fade_out(time := 1.5, scene : String = black_screen.name) -> void:
	tween_fade_in.stop_all()

	tween_fade_out.interpolate_property(get_node(scene), "modulate:a", 1.0, 0.0, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween_fade_out.start()


# Fade in a child sprite
func fade_in(time := 1.5, scene : String= black_screen.name) -> void:
	if (scene != null):
		if not get_node(scene).is_visible():
			get_node(scene).set_visible(true)

		tween_fade_out.stop_all()

		tween_fade_in.interpolate_property(get_node(scene), "modulate:a", 0.0, 1.0, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween_fade_in.start()


func brief_fade_in(amount := 1.0, fade_in_time := 0.3, fade_out_time := 0.3) -> void:
	if not black_screen.is_visible(): black_screen.set_visible(true)

	tween_fade_in.interpolate_property(black_screen, "modulate:a", 0.0, amount, fade_in_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween_fade_in.start()

	yield(tween_fade_in, "tween_all_completed")

	tween_fade_out.interpolate_property(black_screen, "modulate:a", amount, 0.0, fade_out_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween_fade_out.start()


# Show the player's silhoulette during scene transitions
func show_silhoulette() -> void:
	silhoulette.global_position = Vector2(Global.get_player().global_position.x, Global.get_player().position.y - 80.817)
	silhoulette.get_node("AnimationPlayer").play("fade")
