extends Area2D

class_name PairedExitPoint

# Try to make ExitPoints behavior like RPG Maker where ExitPoint works in pairs between two scenes
# To pair them, I'll match their node name ie. 1 pairs to 1, 2 pairs to 2, etc.

export (String, FILE) var exit_scene

export (int, 1, 100) var index = 1

export (String, FILE) var interaction_script

# The scene this exit point is in
onready var coming_from : String
# The scene this exit point leads to
onready var coming_to : String


# Connect signals
func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	if (exit_scene): editor_description = exit_scene


# Dialogue handler
func talk() -> void:
#	print("talking to " + self.name)
	if interaction_script:
		Global.set_can_talk(false)
#		MSG.start_dialogue(interaction_script, self)
		pass
	else:
		printerr("No dialogue found for the player")


# Exit function
func _on_body_entered(body: PhysicsBody2D) -> void:
	if body is Player and exit_scene:
		var current_root := get_tree().current_scene

		# Start an exit dialogue if specified
		if interaction_script:
			talk()
			yield(Global, "dialogue_finished")

		Global.set_next_exit_point(current_root.filename, exit_scene, index)

		current_root.change_scene(exit_scene)
