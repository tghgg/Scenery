extends Area2D

class_name InteractableArea

export (bool) var oneshot = false
export (bool) var blocking = false

onready var collider : CollisionShape2D = $StaticBody2D/CollisionShape2D
onready var interactable_component : InteractableComponent = $InteractableComponent

func _ready() -> void:
	self.connect("area_entered", self, "_on_InteractableArea_area_entered")


# Disable the area
func disable() -> void:
	monitoring = false


# Listener for when the player comes into the area
func _on_InteractableArea_area_entered(area: Area2D) -> void:
	if area.get_parent() is InteractableComponent:
		if (area.get_parent() as InteractableComponent).parent is Player and interactable_component.has_dialogue():
			interactable_component.talk()
			yield(interactable_component, "interactable_dialogue_finished")
			if oneshot: disable()
