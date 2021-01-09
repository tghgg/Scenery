class_name DialogueParser

const EmotesList = preload("EmotesList.gd")
const NodeTypes = preload("NodeTypes.gd")

# Parse the script
static func parse(script : String) -> Array:
	var starting_node : Dictionary = {
		next = "1",
		node_name = "START",
		node_type = "start"
	}

	var master_node : Dictionary = {
		characters = [],
		nodes = [starting_node],
		languages = ["ENG"],
		variables = {},
		editor_version = "2.1"
	}

	var current_node_index := 1;

	var lines : PoolStringArray = script.split("\n")

	for line in lines:
		# Skip the line if it's a comment or it's empty
		if ("//" in line or line.empty()): continue

		# Check if the line consist only of dialogue text
		if len(line.split(":")) == 1:
			# Monologue

			var current_node : Dictionary = {}

			current_node.character = [EmotesList.Emotes.MONO]

			current_node.is_box = true
			current_node.speaker_type = 0

			current_node.text = {
				"ENG": line.strip_edges(),
				"VN": ""
			}

			current_node.slide_camera = false

			current_node.node_name = str(current_node_index)

			current_node.node_type = NodeTypes.SHOW_MESSAGE

			current_node.face = EmotesList.Emotes.NONE

			current_node_index += 1
			current_node.next = str(current_node_index)

			master_node.nodes.append(current_node)
			continue

		var keys : PoolStringArray = line.split(":")[0].split(",")
		var dialogue_text : String = line.split(":")[1].strip_edges()

		# Trim the keys
		for i in range(len(keys)):
			keys.set(i, keys[i].strip_edges())

		# Check if the text has a colon
		if (len(line.split(":")) > 2):
			# Concatenate strings to fix it
			var temp : PoolStringArray = []

			for i in range(len(line.split(":"))):
				temp.append(line.split(":")[i])

			dialogue_text = temp.join(":").strip_edges()

		# Parse the line's keys
		if NodeTypes.EXECUTE in keys:
			var current_node : Dictionary = {
				text = dialogue_text,
				node_name = str(current_node_index),
				node_type = NodeTypes.EXECUTE,
				next = str(current_node_index + 1)
			}
			current_node_index += 1
			master_node.nodes.append(current_node)
		elif NodeTypes.WAIT in keys:
			var current_node : Dictionary = {
				time = float(dialogue_text),
				node_name = str(current_node_index),
				node_type = NodeTypes.WAIT,
				next = str(current_node_index + 1)
			}
			current_node_index += 1
			master_node.nodes.append(current_node)
		else:
			# Normal dialogue
			var current_node : Dictionary = {}

			if (keys[0] == NodeTypes.MONO): keys[0] = EmotesList.Emotes.MONO
			current_node.character = [keys[0]]

			# Add to the master node's characters list
			if not (current_node.character[0] in master_node.characters) and current_node.character[0] != EmotesList.Emotes.MONO:
				master_node.characters.append(current_node.character[0])

			current_node.is_box = true
			current_node.speaker_type = 0

			current_node.text = {
				"ENG": dialogue_text,
				"VN": ""
			}

			current_node.slide_camera = false

			current_node.node_name = str(current_node_index)

			current_node.node_type = NodeTypes.SHOW_MESSAGE

			if len(keys) > 1:
				if EmotesList.has(keys[1]):
					current_node.face = EmotesList.get_emote(keys[1])
				else: # Emotes doesn't exist
					current_node.face = EmotesList.Emotes.NONE
					printerr("Could not find emote for character %s at line %d" % [current_node.character[0], current_node_index])
			elif len(keys) == 1:
				current_node.face = EmotesList.Emotes.NONE

			current_node_index += 1
			current_node.next = str(current_node_index)

			master_node.nodes.append(current_node)

	master_node.nodes[current_node_index - 1].next = null

	# Return the JSON script
	return [master_node]
