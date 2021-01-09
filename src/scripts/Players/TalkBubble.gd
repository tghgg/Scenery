extends Node2D

class_name TalkBubble

onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var sprite : AnimatedSprite = $AnimatedSprite

onready var is_visible setget set_is_visible, get_is_visible

func get_is_visible() -> bool:
	return is_visible

func set_is_visible(value : bool) -> void:
	is_visible = value

func _ready() -> void:
	self.modulate.a = 0
	set_is_visible(false)

	Global.connect("dialogue_finished", self, "_on_dialogue_finished")


func _on_dialogue_finished() -> void:
	# Check if player is still inr vicinity of an NPC with dialogue
	if Global.get_current_body() and Global.get_current_body().has_dialogue():
		show()
	else:
		hide()


func show(anim := "default", play_sfx := true) -> void:
	animation_player.play("create_bubble")
	sprite.play(anim)
	set_is_visible(true)

func hide() -> void:
	animation_player.play("hide_bubble")
	sprite.stop()
	set_is_visible(false)
