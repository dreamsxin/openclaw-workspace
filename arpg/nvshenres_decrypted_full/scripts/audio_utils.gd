extends RefCounted

static func load_mp3_stream(path: String, loop := false) -> AudioStreamMP3:
	if path == "" or not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var stream := AudioStreamMP3.new()
	stream.data = file.get_buffer(file.get_length())
	stream.loop = loop
	return stream

static func play_mp3(player: AudioStreamPlayer, path: String, loop := false) -> bool:
	if player == null:
		return false
	var stream := load_mp3_stream(path, loop)
	if stream == null:
		return false
	player.stop()
	player.stream = stream
	player.play()
	return true
