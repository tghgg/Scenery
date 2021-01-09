extends Control

class_name ChoiceSystem

# Manage the choice buttons and send finished signals to registered ChoiceComponents

# Signal that fires when the choice is picked
signal finished

# The title of the choice
onready var title : Label = $Title
onready var choices : Array = get_children()
onready var choice_count := 0
onready var _is_running := false setget set_is_running, is_running

func set_is_running(value : bool) -> void:
	_is_running = value

func is_running() -> bool:
	return _is_running


func start(title_text : String, data : Dictionary) -> void:
	title.text = title_text.strip_edges()

	choice_count = len(data)

	if choice_count <= 0 or choice_count > 4:
		printerr("The choice count is invalid")
		return

	# Show the choice buttons
	var count := 0
	for choice in get_children():
		if choice is ChoiceButton:
		  choice.show()
		  choice.set_text(data[choice.name]["button_text"])

		  choice.connect("pressed", self, "finish(choice.name)")

		  count += 1
		  if count == choice_count:
			  break

	set_is_running(true)


# Finish the choice
func finish(index : int) -> void:
	# Hide all the choices
	var count := 0
	for choice in get_children():
		if choice is ChoiceButton:
			# Reset the button
			choice.hide()
			choice.disconnect("pressed", self, "finish(choice.name)")
			choice.set_text("")

			count += 1
			if count == choice_count:
				break

	set_is_running(false)

	emit_signal("finished", index)
