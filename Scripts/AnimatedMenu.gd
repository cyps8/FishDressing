extends TextureRect

@export var frames: Array[Texture2D]

var cooldown: float = 0.15

var currentFrame: int = 0

func _process(delta):
	cooldown -= delta
	if cooldown <= 0:
		currentFrame = (currentFrame + 1) % frames.size()
		texture = frames[currentFrame]
		cooldown += 0.15
