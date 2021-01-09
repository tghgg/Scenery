class_name EmotesList

const Emotes : Dictionary = {
	MONO = "None",
	NONE = null,
	NEUTRAL = 0,
	NORMAL = 0 ,
	HAPPY = 1,
	SAD = 2,
	SHOCKED = 3,
	SCARED = 4,
	THINKING = 5 ,
	CURIOUS = 5 ,
	EMBARRASSED = 6,
	WORRIED = 7,
	PRAYING = 8,
	SURPRISED = 9,
}

static func has(emote : String) -> bool:
	return emote.to_upper() in Emotes.keys()

static func get_emote(emote : String) -> int:
	return Emotes[emote.to_upper()] as int
