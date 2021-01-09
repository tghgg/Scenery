extends KinematicBody2D

class_name Player

# String values for player movement animations
const movements = {
	IDLE_FRONT = "idle_front",
	WALKING = "walking"
}

# Color of the name on the dialogue box
export (Color) var color

# How high / low the voice is
export (float, 0.0, 1.9) var voice_pitch

export (int) var speed_scale := 55

export (bool) var talk_on_load := false

export (bool) var auto_set_camera_limit := true

export (bool) var movement_frozen := false

# Initialize variables
onready var acceleration := 200 * speed_scale
onready var max_speed := 500 * speed_scale

onready var motion := Vector2.ZERO
onready var player_animation : AnimatedSprite = $Sprite
onready var current_direction := 0 # Store the direction the player's hearding towards to set the animation correctly
onready var camera : Camera2D = $Camera2D
onready var ui : UIController = camera.get_node("UI")
onready var talk_bubble : TalkBubble = $TalkBubble
onready var interactable_component : InteractableComponent = $InteractableComponent

onready var is_camera_shaking : bool = false
onready var camera_shake_amount_x : float
onready var camera_shake_amount_y : float
onready var camera_pan_amount : float = 1.0

func _ready() -> void:
	# Reset the reference to camera for the MSG_Parser
	Global.dialogue_system.set_current_camera(self.camera)

	# Set camera limit according to level's type and size
	if auto_set_camera_limit:
		print_debug("Auto-set camera limits may cause a crash. Disable 'Auto Set Camera Limit' on the player character if it happens.")

		# HACK: Must use get_node() with stringly typed names here unfortunately
		var map = get_tree().current_scene.get_node("BG/Map")
		camera.limit_right = map.get_used_rect().size.x * map.scale.x * map.cell_size.x
		camera.limit_bottom = map.get_used_rect().size.y * map.scale.y * map.cell_size.y

	# Setup listeners to detect when NPCs are in the player's vicinity
	interactable_component.area.connect("area_entered", self, "_on_InteractableArea_entered")
	interactable_component.area.connect("area_exited", self, "_on_InteractableArea_exited")


# Interaction with NPCs and objects handler
func _on_InteractableArea_entered(body: Area2D) -> void:
	if body.get_parent() is InteractableComponent:
		var current_npc : InteractableComponent = body.get_parent()

		Global.set_current_body(current_npc)

		if current_npc.has_dialogue(): talk_bubble.show()

func _on_InteractableArea_exited(_body: Area2D) -> void:
	Global.set_current_body(null)

	if talk_bubble.is_visible: talk_bubble.hide()


func freeze_movement() -> void:
	print_debug("Freezing player movement")
	movement_frozen = true

func unfreeze_movement() -> void:
	print_debug("Allowing player movement")
	movement_frozen = false


# Core loop
func _physics_process(delta: float) -> void:
	# Shake the camera
	if is_camera_shaking:
		camera.set_offset(Vector2(rand_range(-1.0, 1.0) * camera_shake_amount_x, rand_range(-1.0, 1.0) * camera_shake_amount_y))
		if camera_shake_amount_x != 0: camera_shake_amount_x -= 0.1
		if camera_shake_amount_y != 0: camera_shake_amount_y -= 0.1

	# Open game settings when ESC is pressed
	if Input.is_action_just_pressed(Global.player_input.OPEN_SETTINGS):
		if not ui.settings_menu.visible and not Global.dialogue_system.is_dialogue_happening() and not Global.get_player().movement_frozen:
			ui.open_settings()
		elif ui.settings_menu.visible and Global.get_player().movement_frozen and not Global.dialogue_system.is_dialogue_happening():
			ui.close_settings()
		return

	# Check whether player is in dialogue
	# If in dialogue then freeze all movement until dialogue is finished
	if not movement_frozen:
		# Talk
		if Input.is_action_just_pressed(Global.player_input.INTERACT) and Global.get_current_body():
			print_debug("Talking to " + Global.get_current_body().parent.name)
			talk_bubble.hide()
			Global.get_current_body().talk()

		# Vertical movement
		if Input.is_action_pressed(Global.player_input.MOVE_UP):
			motion.y = max(motion.y - acceleration, -max_speed)
			player_animation.play(movements.WALKING)
			current_direction = -1
			camera.set_v_offset(-camera_pan_amount)
		elif Input.is_action_pressed(Global.player_input.MOVE_DOWN):
			motion.y = min(motion.y + acceleration, max_speed)
			player_animation.play(movements.WALKING)
			current_direction = 1
			camera.set_v_offset(camera_pan_amount)
		else:
			camera.set_v_offset(0.0)
			motion.y = 0

		# Sideway movement
		if Input.is_action_pressed(Global.player_input.MOVE_RIGHT):
			motion.x = min(pow(motion.x, 2.0) + acceleration, max_speed)
			player_animation.play(movements.WALKING)
			current_direction = 2
		elif Input.is_action_pressed(Global.player_input.MOVE_LEFT):
			motion.x = max(-pow(motion.x, 2.0) - acceleration, -max_speed)
			player_animation.play(movements.WALKING)
			current_direction = 2
		else:
			motion.x = lerp(motion.x, 0.0, 1.0)

		# Play idle animation based on current direction if standing still
		if motion == Vector2.ZERO:
			match(current_direction):
				-1: # Backward
					player_animation.play(movements.IDLE_FRONT)
				0: # Idle
					player_animation.play(movements.IDLE_FRONT)
				1: # Forward
					player_animation.play(movements.IDLE_FRONT)
				2: # Sideways
					player_animation.play(movements.IDLE_FRONT)
	else:
		## Movement is frozen ##

		motion = Vector2.ZERO

		match(current_direction):
			-1: # Backward
				player_animation.play(movements.IDLE_FRONT)
			0: # Idle
				player_animation.play(movements.IDLE_FRONT)
			1: # Forward
				player_animation.play(movements.IDLE_FRONT)
			2: # Sideways
				player_animation.play(movements.IDLE_FRONT)

		# Advance the dialogue when dialogue is happening
		if Input.is_action_just_pressed(Global.player_input.ADVANCE_DIALOGUE):
			# Check if the settings menu is open
			if ui.settings_menu.is_visible(): return

			# If menu hidden then it means that there is a dialogue happening
			if Global.dialogue_system.is_dialogue_happening(): Global.dialogue_system.advance_dialogue()

	# move with 'motion' speed, the up direction is y=1, and stop on slopes
	move_and_slide(motion * delta)


# Camera panning
func pan_camera(axis: String, amount := 150.0, time := 1.0) -> void:
	if axis == "x" || axis == "y":
		camera.get_node("Pan").interpolate_property(camera, "offset:%s" % axis, camera["offset"][axis], amount, time, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
		camera.get_node("Pan").start()

func reset_pan_camera(time := 1.0) -> void:
	pan_camera("x", 0.0, time)
	pan_camera("y", 0.0, time)


# Letterboxing
func letterbox(type := "screen_center") -> void:
	var top_bar : Sprite = camera.get_node("Letterbox/TopBar")
	var bottom_bar : Sprite = camera.get_node("Letterbox/BottomBar")

	### Set the black bars position correctly when the player is near the camera limits
	# Works for panned camera
	if type == "screen_center":
		if camera.get_camera_screen_center().y - 540 * camera.zoom.y <= 0:
			top_bar.global_position.y = 0
			bottom_bar.global_position.y = 1080 * camera.zoom.y
		elif camera.get_camera_screen_center().y + 540 >= camera.limit_bottom:
			bottom_bar.global_position.y = camera.limit_bottom
			top_bar.global_position.y = camera.limit_bottom - 1080 * camera.zoom.y
		else:
			top_bar.global_position.y = camera.get_camera_screen_center().y - 540 * camera.zoom.y
			bottom_bar.global_position.y = camera.get_camera_screen_center().y + 540 * camera.zoom.y
	# Works for on-the-fly cutscenes
	elif type == "current":
		if camera.get_camera_position().y - 540 <= 0:
			top_bar.global_position.y = 0
			bottom_bar.global_position.y = 1080
		elif camera.get_camera_position().y + 540 >= camera.limit_bottom:
			bottom_bar.global_position.y = camera.limit_bottom
			top_bar.global_position.y = camera.limit_bottom - 1080
		else:
			top_bar.global_position.y = camera.get_camera_position().y - 540 * camera.zoom.y
			bottom_bar.global_position.y = camera.get_camera_position().y + 540 * camera.zoom.y

	camera.get_node("Letterbox/AnimationPlayer").play("slide")

func hide_letterbox() -> void:
	camera.get_node("Letterbox/AnimationPlayer").play_backwards("slide")


# Shake the camera
func shake_camera(duration := 2.0, amount_x := 3.0, amount_y := 3.0) -> void:
	is_camera_shaking = true
	camera_shake_amount_x = amount_x
	camera_shake_amount_y = amount_y
	yield(get_tree().create_timer(duration), "timeout")
	is_camera_shaking = false
	camera.set_offset(Vector2.ZERO)
