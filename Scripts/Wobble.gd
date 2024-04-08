extends TextureRect

@export var speed: float = 0.25

func _ready():
	pivot_offset = size * 0.5
	var animateTween: Tween = create_tween().set_loops(-1)
	animateTween.tween_property(self, "rotation", deg_to_rad(15), speed).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	animateTween.tween_property(self, "rotation", deg_to_rad(0), speed).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	animateTween.tween_property(self, "rotation", deg_to_rad(-15), speed).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	animateTween.tween_property(self, "rotation", deg_to_rad(0), speed).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)