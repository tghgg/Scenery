extends Node2D

class_name EffectsController

func enable_effect(name : String, param := "play") -> void:
	print_debug("Enabling the VFX '%s' with the clip '%s'" % [name, param])
	get_effect(name).play(param)


func disable_effect(name : String) -> void:
	print_debug("Disabling the VFX '%s' with the clip '%s'" % name)
	get_effect(name).stop()


func reverse_effect(name : String, param := "play") -> void:
	print_debug("Reversing the VFX '%s' with the clip '%s'" % [name, param])
	get_effect(name).play_backwards(param)


func pause_effect(name : String) -> void:
	print_debug("Pausing the VFX '%s'" % name)
	get_effect(name).pause()


func hide_effect(name : String, param := "hide") -> void:
	print_debug("Hide the VFX '%s' with the clip '%s'" % [name, param])
	get_effect(name).hide(param)


func get_effect(name : String) -> Effect:
	return get_node(name.strip_edges()) as Effect
