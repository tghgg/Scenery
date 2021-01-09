class_name DialogueSystem

onready var _dialogue_happening := false setget set_is_dialogue_happening, is_dialogue_happening

onready var choice_system : ChoiceSystem = preload("./ChoiceSystem.gd").new()

func set_current_camera(camera : Camera2D) -> void:
#	MSG.camera = camera
	pass


func set_is_dialogue_happening(value : bool) -> void:
	_dialogue_happening = value

func is_dialogue_happening() -> bool:
	return _dialogue_happening


func advance_dialogue() -> void:
#	MSG.next()
	pass


func show_dialogue_box() -> void:
#	MSG_Box.show()
	pass


func hide_dialogue_box() -> void:
#	MSG_Box.hide()
	pass
