extends Node

class_name AudioPlayer

static var ins: AudioPlayer

enum SoundType { MASTER = 0, MUSIC = 1, SFX = 2}

@export var sounds: Array[AudioStream]

@export var fishSounds: Array[AudioStream]

@export var materialSounds: Array[AudioStream]

func _ready():
	ins = self

	for sound in sounds:
		load(sound.get_path())

func PlaySound(soundId: int, type: SoundType = SoundType.SFX, volume: float = 1, pitch: float = 1) -> void:
	var sound: AudioStreamPlayer = AudioStreamPlayer.new()
	sound.stream = sounds[soundId]
	sound.bus = AudioServer.get_bus_name(type)
	sound.volume_db = linear_to_db(volume)
	sound.pitch_scale = pitch
	
	add_child(sound)
	sound.finished.connect(Callable(sound.queue_free))
	sound.play()

func PlayFishSound(soundId: int, type: SoundType = SoundType.SFX, volume: float = 1, pitch: float = 1) -> void:
	var sound: AudioStreamPlayer = AudioStreamPlayer.new()
	sound.stream = fishSounds[soundId]
	sound.bus = AudioServer.get_bus_name(type)
	sound.volume_db = linear_to_db(volume)
	sound.pitch_scale = pitch
	
	add_child(sound)
	sound.finished.connect(Callable(sound.queue_free))
	sound.play()

func PlayMatSound(soundId: int, type: SoundType = SoundType.SFX, volume: float = 1, pitch: float = 1) -> void:
	var sound: AudioStreamPlayer = AudioStreamPlayer.new()
	sound.stream = materialSounds[soundId]
	sound.bus = AudioServer.get_bus_name(type)
	sound.volume_db = linear_to_db(volume)
	sound.pitch_scale = pitch
	
	add_child(sound)
	sound.finished.connect(Callable(sound.queue_free))
	sound.play()