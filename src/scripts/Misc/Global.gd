extends Node

# Signal fired on finishing a dialogue
signal dialogue_finished

# Avoid stringly typed signal names with this
const dialogue_finished_signal_name := "dialogue_finished"

# Dev environment
const env := "dev"

# Temporary container for global variables
const temp_variables : Dictionary= { }

onready var groups : Groups = preload("./Groups.gd").new()
onready var player_input : PlayerInput = preload("./Input.gd").new()
onready var save_system : SaveSystem = preload("./SaveSystem.gd").new()
onready var dialogue_system : DialogueSystem = preload("./DialogueSystem.gd").new()

onready var next_exit_point : PairedExitPoint

# The resource path for the currently playing song
onready var current_music : String

onready var current_player_name := "Evan"

onready var _can_talk := true setget set_can_talk, get_can_talk

onready var _current_scene: GameScene setget set_current_scene, get_current_scene

onready var _current_body: InteractableComponent setget set_current_body, get_current_body

func _ready() -> void:
	if self.save_system.get_save_data() and self.env != "dev": return

	# Create a save file if one doesn't exist
	var save_file := File.new()

	save_file.open(self.save_system.save_name, File.WRITE)
	save_file.store_line(to_json({
	"Global": {
		"current_scene": null
	}}))

	save_file.close()


# Manage temporary variables
func set_temp_variable(name : String, value) -> void:
	temp_variables[name.strip_edges()] = value

func get_temp_variable(name : String):
	return temp_variables.get(name.strip_edges())

func has_temp_variable(name : String) -> bool:
	return name.strip_edges() in temp_variables

func remove_temp_variable(name : String) -> void:
	temp_variables.erase(name.strip_edges())


# Set flags on the save file level
func add_flag(name : String, value) -> void:
	pass
func get_flag(name : String):
	pass
func remove_flag(name : String) -> void:
	pass
func update_flag(name : String, value) -> void:
	pass


# Manage exit points
func set_next_exit_point(coming_from : String, coming_to : String, index : int) -> void:
	var exit_point : PairedExitPoint = PairedExitPoint.new();
	exit_point.coming_from = coming_from
	exit_point.coming_to = coming_to
	exit_point.index = index
	next_exit_point = exit_point

func get_next_exit_point() -> PairedExitPoint:
	return next_exit_point


# Dialogue check getters and setters
func set_can_talk(value: bool, emit_signal := true) -> void:
	_can_talk = value

	if value and emit_signal:
		emit_signal("dialogue_finished")

func get_can_talk() -> bool:
	return _can_talk


# Information about the currently playing scene
func set_current_scene(value: GameScene) -> void:
	_current_scene = value

func get_current_scene() -> GameScene:
	return _current_scene


# Current body the player is interacting with check getters and setters
func set_current_body(value: InteractableComponent) -> void:
	_current_body = value

func get_current_body() -> InteractableComponent:
	return _current_body


# Return the player character
func get_player() -> Player:
	# HACK: Add this check because this function will get called before Global is finished initializing
	if self.groups == null: self.groups = preload("Groups.gd").new()

	return get_tree().get_nodes_in_group(self.groups.player_group).front() as Player


# Freeze all game movement
func freeze() -> void:
	return
