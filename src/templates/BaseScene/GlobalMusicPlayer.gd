extends AudioStreamPlayer

# Fade in songs
func set_music(new_song: String, position_to_play_from := 0.0) -> void:
	# Fade out the playing song and fade in the new song
	if load(new_song) as AudioStream and self.get_stream() != load(new_song):
		stop_music()
		yield($FadeOut, "tween_all_completed")
		self.set_stream(load(new_song))
		self.play(position_to_play_from)

		$FadeOut.interpolate_property(self, "volume_db", null, 0.0, 2.0)
		$FadeOut.start()
	elif self.get_stream() == load(new_song) and not self.is_playing():
		self.play(position_to_play_from)

		$FadeOut.interpolate_property(self, "volume_db", null, 0.0, 2.0)
		$FadeOut.start()
	else:
		print("Invalid music resource")


# Get the currently playing song
func get_music() -> AudioStream:
	return self.get_stream() as AudioStream


# Fade out the playing song
func stop_music() -> void:
	$FadeOut.interpolate_property(self, "volume_db", null, -50.0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$FadeOut.start()
	yield($FadeOut, "tween_all_completed")
	self.stop()


# Set global volume
func set_volume(new_volume: float) -> void:
	AudioServer.set_bus_volume_db(0, new_volume)


# Get the global volume
func get_volume() -> float:
	return AudioServer.get_bus_volume_db(0)
