extends Node2D

class_name ChoiceComponent

# Component that allows an InteractableComponent to have choices

# Associated dialogues for the choices
export (Dictionary) var choice_data = {}

# The text to show when the player is making the choice
export (String) var choice_title = ""

onready var parent : InteractableComponent = get_parent()

onready var json_scripts : PoolStringArray

func _ready() -> void:
	for script in choice_data:
		if script:
			if script.code and script.button_text:
			  json_scripts.append(DialogueParser.parse(script.code.strip_edges()))


# Start the choice
func start() -> void:
	Global.dialogue_system.choice_system.start(choice_title, choice_data)

	# Add the listener
	self.connect("finished", Global.dialogue_system.choice_system, "_on_choice_finished(index)")


# Fire the corresonding script when a choice is picked
func _on_choice_finished(index : int) -> void:
	if index > len(json_scripts):
		printerr("Invalid choice index '%d'" % index)
		return

	parent.json_scripts.clear()
	parent.json_scripts.append(self.json_scripts[index])
	parent.json_scripts.talk()

	self.disconnect("finished", Global.dialogue_system.choice_system, "_on_choice_finished(index)")
