extends Node2D

export (String, FILE) var intro_scene

# Scene to show development progress
export (String, FILE) var progress_scene

export (String, FILE) var music_to_play

onready var transition := $Transition

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	transition.fade_out()
	# Start music
	if music_to_play:
		GlobalMusicPlayer.set_music(music_to_play)
		GlobalMusicPlayer.set_volume(GlobalMusicPlayer.get_volume())

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("open_settings"):
		_on_MenuButton_pressed()

# Start button
func _on_Start_pressed() -> void:
	# Fancy animation
	transition.fade_in()
	transition.get_node("Logo").visible = true
	transition.get_node("Orbs2").self_modulate = Color(1.0, 1.0, 1.0, 1.0)

	# Reset Global variables
	var save_file := File.new()
# warning-ignore:return_value_discarded
	save_file.open(Global.save_system.save_name, File.WRITE)
	save_file.store_line(to_json({
	"Global": {
		"current_scene": null
	}}))
	save_file.close()
	yield(get_tree().create_timer(3.0), "timeout")
	GlobalMusicPlayer.stop_music()

	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	get_tree().change_scene(intro_scene)

# Exit button
func _on_Exit_pressed() -> void:
	transition.fade_in()
	yield(get_tree().create_timer(1.5), "timeout")
	get_tree().quit()

# Load the save file
func _on_Load_pressed() -> void:
	var save_data: Dictionary = Global.save_system.get_save_data()

	# Load the last scene the player was in
	if save_data.get("Global").get("current_scene") != null:
		# Disable all buttons
		_on_any_Button_pressed()

		# Change to the loaded scene
		transition.fade_in()

		yield(get_tree().create_timer(2.0), "timeout")

		GlobalMusicPlayer.stop_music()

		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

		# Set the last played music
		if save_data.get("Global").get("playing_song") != "":
			GlobalMusicPlayer.set_music(save_data.get("Global").get("playing_song"))

		get_tree().change_scene(save_data.get("Global").get("current_scene"))

	# Warn if save file doesn't exist
	$Control/NoSave.popup()
	yield(get_tree().create_timer(2.0), "timeout")
	$Control/NoSave.hide()


# Disable other buttons once a button is pressed
func _on_any_Button_pressed() -> void:
	for node in $Control.get_children():
		if node as TextureButton:
			node.disabled = true


# Open settings
func _on_MenuButton_pressed() -> void:
	var settings_menu := $Control/SettingsMenu
	if not $Control/SettingsMenu.visible:
		settings_menu.visible = true
		settings_menu.get_node("AnimationPlayer").play("fade")
		settings_menu.get_node("Sidebar/VBoxContainer/Settings").grab_focus()
	else:
		settings_menu.get_node("AnimationPlayer").play_backwards("fade")
		yield(settings_menu.get_node("AnimationPlayer"),"animation_finished")
		settings_menu.visible = false


func _on_Start2_pressed() -> void:
	# Fancy animation
	transition.fade_in()
	transition.get_node("Logo").visible = true
	transition.get_node("Orbs2").self_modulate = Color(1.0, 1.0, 1.0, 1.0)

	# Reset Global variables
	var save_file := File.new()
# warning-ignore:return_value_discarded
	save_file.open(Global.save_system.save_name, File.WRITE)
	save_file.store_line(to_json({
	"Global": {
		"current_scene": null
	}}))
	save_file.close()

	yield(get_tree().create_timer(3.0), "timeout")

	GlobalMusicPlayer.stop_music()

	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	get_tree().change_scene(progress_scene)
