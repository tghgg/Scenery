extends Node

class_name Effect

onready var player : AnimationPlayer = $AnimationPlayer


func play(name := "play") -> void:
	player.play(name)


func stop(name := "stop") -> void:
	player.play(name)


func pause() -> void:
	player.stop(false)


func play_backwards(name := "play") -> void:
	player.play_backwards(name)

func hide(name := "hide") -> void:
	player.play(name)


