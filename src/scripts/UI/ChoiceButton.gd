extends Button

class_name ChoiceButton

onready var animation_player : AnimationPlayer = $AnimationPlayer

func show() -> void:
	self.disabled = false
	animation_player.play("show")

func hide() -> void:
	self.disabled = true
	animation_player.play("hide")

# Set the text for the button
func set_text(text : String) -> void:
	self.text = text.strip_edges()

# Don't allow the player to pick the choice
func disable() -> void:
	pass
