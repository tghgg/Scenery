extends Button

export (String, FILE) var script_throw

onready var rock_index := 1

func _ready() -> void:
	yield(get_tree().create_timer(1.5), "timeout")
	$AnimationPlayer.play("fade")

func _on_ThrowButton_pressed() -> void:
	print_debug("Eat rock!")
	$AnimationPlayer.play("disappear")
	if not rock_index == 3:
		get_node("../../../Rock%d/Sprite2/AnimationPlayer" % rock_index).play("throw") 
		get_node("../../../Rock%d" % rock_index).set_visible(true)

	rock_index += 1
	yield(get_tree().create_timer(0.2), "timeout")
	if not rock_index == 4:
		Global.shake_camera(true, 0.4)
		$Flash/AnimationPlayer.play("flash")
	talk()
	yield(Global, "dialogue_finished")

	if rock_index > 4:
		
#		get_parent().get_parent().get_parent().pan_camera("y", -200, 1.0)
		
#		yield(get_tree().create_timer(1.0), "timeout")
		
		get_tree().current_scene.change_scene("res://src/Scenes/Intro/Plane1/Day2/ScarletSquareEnd.tscn", 3.0)
		
		return
#		queue_free()
	else:
		yield(get_tree().create_timer(1.0), "timeout")
		$AnimationPlayer.play("fade")
	script_throw = "res://assets/dialogues/JSON Dialogues/Day2-Morning/ScarletSquareMinigameThrow%d.json" % (rock_index - 1)
	get_parent().get_parent().get_parent().camera_shake_amount_x += 5
	get_parent().get_parent().get_parent().camera_shake_amount_y += 5
func talk() -> void:
	Global.set_can_talk(false)
	MSG.start_dialogue(script_throw)
	
