extends Node2D

class_name DisappearingComponent

export (String) var disappearing_condition

onready var parent = get_parent()

func _ready() -> void:
	if disappearing_condition:
		print_debug("Evaluating disappearing condition for '%s'" % parent.name)
		if evaluate(disappearing_condition.strip_edges()):
			print_debug("Disappearing condition for '%s' fulfilled, removing it from the scene" % parent.name)
			parent.queue_free()


func evaluate(input):
	var script = GDScript.new()
	script.set_source_code("func eval():\n\treturn " + input)
	script.reload()
	var obj = Reference.new()
	obj.set_script(script)
	return obj.eval()
