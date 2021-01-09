extends Node2D

signal interactable_dialogue_started
signal interactable_dialogue_finished

class_name InteractableComponent

# Color of the character's title text
export (Color) var color

# How high / low the voice is
export (float, 0.0, 1.9) var voice_pitch

# Dialogue files
export (Array, String, FILE, "*.txt") var interaction_scripts = [""]

export (String, MULTILINE) var flash_dialogue = ""

# Whether the NPC's dialogues will loop
export (bool) var looping = false

# Whether the interactable can still be talked to later when the player returns to the scene
export (bool) var oneshot = false

onready var dialogue_index := 0

onready var json_scripts : Array = []

onready var area : Area2D = $Area2D

onready var parent = get_parent()

onready var is_parsed := false

# Convert the dialogue script to JSON to feed into the MSG_Parser
func parse() -> void:
	if not flash_dialogue.empty():
		json_scripts.push_front(DialogueParser.parse(flash_dialogue))

	for script in interaction_scripts:
		if script:
			# Read from the script file
			var f = File.new()
			f.open(script, File.READ)
			# Add to the JSON scripts list
			var parse_result : Array = DialogueParser.parse(f.get_as_text())
			json_scripts.append(parse_result)
			f.close()

	is_parsed = true


func has_dialogue() -> bool:
	if not is_parsed: parse()
	return len(json_scripts) > 0 and dialogue_index < len(json_scripts)


func disable() -> void:
	json_scripts.clear()

	
func interact() -> void:
	if has_dialogue():
		Global.dialogue_system.set_is_dialogue_happening(true)

		Global.set_current_body(self)

		Global.get_player().freeze_movement()

#		MSG.start_dialogue(json_scripts[dialogue_index], self)

		emit_signal("interactable_dialogue_started")

		dialogue_index += 1

		# Handles when the interactable is out of dialogues
		if dialogue_index > len(json_scripts) - 1:
			if looping:
				# Loop the dialogue
				dialogue_index = 0
			if oneshot:
				# Mark for removal on re-entering the scene in the save file
				print_debug("Removing the interactable on scene exit")

				var current_scene_name = get_tree().current_scene.filename

				var current_save_data = Global.save_system.get_save_data()

				if current_save_data.has(current_scene_name):
					if not current_save_data[current_scene_name].has(Global.groups.oneshot_interactables):
						current_save_data[current_scene_name][Global.groups.oneshot_interactables] = {}

					current_save_data[current_scene_name][Global.groups.oneshot_interactables][get_parent().name] = get_path()

					# Set the save file to the new save with the subkey added
					Global.save_system.set_save_data(current_scene_name, current_save_data[current_scene_name][Global.groups.oneshot_interactables], Global.groups.oneshot_interactables)

		yield(Global, "dialogue_finished")

		Global.get_player().unfreeze_movement()

		Global.dialogue_system.set_is_dialogue_happening(false)

		emit_signal("interactable_dialogue_finished")

	else:
		printerr('No dialogue available for the character')
