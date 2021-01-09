extends Control

class_name SettingsMenu

onready var karma_menu := $Panel/TabContainer/Karma/TabContainer
onready var previous_button := $Panel/TabContainer/Karma/Previous
onready var next_button := $Panel/TabContainer/Karma/Next
onready var tab_container := $Panel/TabContainer
onready var animation_player := $AnimationPlayer
onready var settings_button : Button = $Sidebar/VBoxContainer/Settings


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_visible(false)
	$Panel/TabContainer/Settings/VBoxContainer/CheckBox.pressed = OS.is_window_fullscreen()


# Listeners

func _on_TabContainer_tab_changed(tab: int) -> void:
	previous_button.visible = true
	next_button.visible = true
	if tab == 0:
		previous_button.visible = false
	elif tab == len(karma_menu.get_children())-1:
		next_button.visible = false


func _on_CheckBox_toggled(button_pressed) -> void:
	OS.set_window_fullscreen(button_pressed)


func _on_Quit_pressed() -> void:
	set_visible(false)

	Global.get_player().freeze_movement()

	if GlobalMusicPlayer.is_playing():
	  Global.save_system.set_save_data("Global", GlobalMusicPlayer.get_music().resource_path, "playing_song")
	else:
	  Global.save_system.set_save_data("Global", "playing_song", "")

	get_tree().current_scene.change_scene("res://src/Scenes/Title.tscn", 0.6, false)


func _on_Close_pressed() -> void:
	Global.get_player().ui.close_settings()


func _on_Settings_pressed() -> void:
	tab_container.current_tab = 0


func _on_Karma_pressed() -> void:
	tab_container.current_tab = 1


# Karma list events
func _on_Next_pressed() -> void:
	karma_menu.current_tab += 1


func _on_Previous_pressed() -> void:
	karma_menu.current_tab -= 1
