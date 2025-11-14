class_name MusicPlayer extends AudioStreamPlayer

static var ins: MusicPlayer

func _init():
	ins = self

func SetMusic(id: int):
	self.get_stream_playback().switch_to_clip(id)