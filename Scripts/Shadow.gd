extends TextureButton

@export var speed: float = 0.25
@export var rotationLimit: float = 15

func _ready():
	var animateTween: Tween = create_tween().set_loops(-1)
	animateTween.tween_property(self, "rotation", deg_to_rad(rotationLimit), speed).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	animateTween.tween_property(self, "rotation", deg_to_rad(0), speed).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	animateTween.tween_property(self, "rotation", deg_to_rad(-rotationLimit), speed).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	animateTween.tween_property(self, "rotation", deg_to_rad(0), speed).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)