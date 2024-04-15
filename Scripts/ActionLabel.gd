extends Label

func _ready():
	var fadeTween: Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	fadeTween.tween_interval(2.5)
	fadeTween.tween_property(self, "modulate", Color(1, 1, 1, 0), 1.5)
	fadeTween.tween_callback(queue_free)