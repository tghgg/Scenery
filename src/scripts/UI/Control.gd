extends CanvasLayer

class_name UIController

onready var popup_indicator : Popup = $SaveIndicator/Popup
onready var settings_menu : SettingsMenu = $SettingsMenu

func popup_element(menu: String, time_until_hidden:= 0) -> void:
	get_node("%s/Popup" % menu).popup()
	if time_until_hidden != 0:
		yield(get_tree().create_timer(time_until_hidden), "timeout")
		popup_indicator.get_node("AnimationPlayer").play_backwards("fade")
		yield(popup_indicator.get_node("AnimationPlayer"), "animation_finished")
		get_node("%s/Popup" % menu).hide()

func hide_element(menu: String) -> void:
	get_node("%s/Popup" % menu).hide()

func open_settings() -> void:
	Global.get_player().freeze_movement()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	settings_menu.visible = true
	settings_menu.animation_player.play("fade")
	settings_menu.tab_container.current_tab = 0
	settings_menu.settings_button.grab_focus()
func close_settings() -> void:
	Global.get_player().unfreeze_movement()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	settings_menu.animation_player.play_backwards("fade")
	yield(settings_menu.animation_player, "animation_finished")
	settings_menu.visible = false

func _on_Popup_about_to_show() -> void:
	popup_indicator.get_node("AnimationPlayer").play("fade")
