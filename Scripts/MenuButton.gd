extends Button

var scaleTween: Tween
var wobbleTween: Tween

@export var silentButton: bool = false
@export var disableForWeb: bool = false
@export var backButton: bool = false

@export var wobbleDegrees: float = 3.0

func _ready():
	if OS.get_name() == "Web" && disableForWeb:
		disabled = true

	mouse_entered.connect(Callable(_Focused))
	mouse_exited.connect(Callable(_Unfocused))
	focus_entered.connect(Callable(_Focused))
	focus_exited.connect(Callable(_Unfocused))
	pressed.connect(Callable(_Pressed))

	if pivot_offset == Vector2(0, 0):
		pivot_offset = size/2

	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _Focused():
	if disabled:
		return
	if scaleTween:
		scaleTween.stop()
	if wobbleTween:
		wobbleTween.stop()
	scaleTween = create_tween()
	scaleTween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
	wobbleTween = create_tween().set_loops(-1)
	wobbleTween.tween_property(self, "rotation", deg_to_rad(wobbleDegrees), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	wobbleTween.tween_property(self, "rotation", deg_to_rad(0), 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	wobbleTween.tween_property(self, "rotation", deg_to_rad(-wobbleDegrees), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	wobbleTween.tween_property(self, "rotation", deg_to_rad(0), 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	AudioPlayer.ins.PlaySound(1)
	if !focus_mode == FOCUS_NONE && !has_focus():
		grab_focus()

func _Pressed():
	if !silentButton:
		if backButton:
			AudioPlayer.ins.PlaySound(3)
		else:
			AudioPlayer.ins.PlaySound(2)

func _Unfocused():
	if scaleTween:
		scaleTween.stop()
	if wobbleTween:
		wobbleTween.stop()
	scaleTween = create_tween()
	scaleTween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
	wobbleTween = create_tween()
	wobbleTween.tween_property(self, "rotation", deg_to_rad(0), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
