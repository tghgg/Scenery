extends Node2D

class_name GameScene

export (String, FILE) var next_scene

export (Array, String, FILE) var music_to_play = [""]

export (bool) var temporary_song = false
export (bool) var stop_music = false

onready var map = $BG
onready var cg_handler : CgHandler = $CGHandler
onready var transitioner : Transitioner = $Transitioner
onready var effects_controller : EffectsController = $Effects
onready var characters = map.get_node("WorldLayer")
onready var level_sprite : Sprite = map.get_node("Base/Sprite")

onready var player : Player
onready var ui : UIController

# Set up the scene
func _ready() -> void:
	Global.set_current_scene(self)

	# Play the level's theme
	if music_to_play:
		if temporary_song and GlobalMusicPlayer.get_music():
			Global.current_music = GlobalMusicPlayer.get_music().resource_path
			GlobalMusicPlayer.set_music(music_to_play.front())
		elif not stop_music:
			# Don't play the music automatically
			GlobalMusicPlayer.set_music(music_to_play.front())
	else:
		# Play a previous theme
		if Global.current_music:
			GlobalMusicPlayer.set_music(Global.current_music)
			Global.current_music = ""
		elif stop_music:
			GlobalMusicPlayer.stop_music()

	# Fade in the scene
	transitioner.visible = true
	transitioner.fade_out()

	player = get_tree().get_nodes_in_group(Global.groups.player_group).front() as Player

	if player != null:
		ui = player.ui

		# SAVE DATA HANDLING HERE
		# Usually will set up story stuff based on the save data
		var save_data : Dictionary = Global.save_system.get_save_data()

		# Probably do some story stuff here

		if save_data.has(self.filename):
			print_debug("Loading from save")

			find_exit_points()

			# Remove oneshot interactables
			if save_data.get(self.filename).has(Global.groups.oneshot_interactables):
				# var oneshot_interactables : PoolStringArray = save_data.
				var temp = save_data.get(self.filename).get(Global.groups.oneshot_interactables).values()
				for path in save_data.get(self.filename).get(Global.groups.oneshot_interactables).values():
					(get_node(path) as InteractableComponent).disable()

			# Godot 3.2.2 camera hack
			yield(get_tree(), "idle_frame")
			yield(get_tree(), "idle_frame")

			player.camera.smoothing_enabled = true

			# Don't automatically start a dialogue
			player.talk_on_load = false

			player.unfreeze_movement()
		else:
			print_debug("Creating new save entry for this level")

			# Update save data and autosave
			ui.popup_element("SaveIndicator", 2)

			# Create the save entry for the level
			Global.save_system.set_save_data(self.filename, {})

			Global.save_system.set_save_data("Global", self.filename, "current_scene")

			find_exit_points()

			# Godot 3.2.2 camera hack
			yield(get_tree(), "idle_frame")
			yield(get_tree(), "idle_frame")

			player.camera.smoothing_enabled = true

			# Stuff to do
			Global.set_can_talk(true, false)

			if player.interactable_component.has_dialogue() and player.talk_on_load:
				# Start a dialogue
				player.freeze_movement()

				yield(get_tree().create_timer(1.0), "timeout")

				player.interactable_component.talk()

				yield(Global, Global.dialogue_finished_signal_name)

				player.unfreeze_movement()


# Set the position of the player according to the last time the player was in this scene
func find_exit_points() -> void:
	if Global.next_exit_point:
		Global.set_can_talk(true)
		var exit_point_found := false

		for node in get_tree().get_nodes_in_group(Global.groups.exit_points_group):
			if node.index == Global.next_exit_point.index and get_tree().current_scene.filename == Global.next_exit_point.coming_to and node.exit_scene == Global.next_exit_point.coming_from:
				exit_point_found = true
				Global.next_exit_point = null

				player.global_position.x = node.global_position.x
				player.global_position.y = node.global_position.y

				# Temporarily disable the exit point
				node.monitoring = false
				yield(get_tree().create_timer(1.0), "timeout")
				node.monitoring = true

				break
		# Throw error if couldn't find the exit node required
		if not exit_point_found:
			printerr("COULD NOT FIND PAIRED EXIT NODE FOR NODE: %s" % Global.next_exit_point)


# Helper for smoothly changing scenes
func change_scene(scene := next_scene, time := 0.6, delay_between_scenes := 0.5) -> void:
	# Fade to black and freeze player input and movement
	Global.get_player().freeze_movement()

	transitioner.fade_in(time)

	yield(get_tree().create_timer(time + delay_between_scenes), "timeout")

	get_tree().change_scene(scene)
