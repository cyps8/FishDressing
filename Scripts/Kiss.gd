extends Sprite2D

func _ready():
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
	tween.tween_callback(queue_free)