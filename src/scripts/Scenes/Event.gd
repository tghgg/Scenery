extends StaticBody2D

class_name Event

export (int, "Touch", "On Interact Pressed") var activation_type
export (int, "Dialogue", "Trigger") var event_type

onready var interactable : InteractableComponent = $InteractableComponent
onready var shape : CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# Setup the activation type
	if activation_type == 0: # Touch as activation
		interactable.area.monitoring = true
		interactable.area.connect("area_entered", self, "_on_Area2D_area_entered")
	elif activation_type == 1:	
		interactable.area.monitorable = true


func _on_Area2D_area_entered(area : Area2D) -> void:
	if area.parent is InteractableComponent:
		if (area.parent as InteractableComponent).parent is Player:
			interactable.interact()
	
