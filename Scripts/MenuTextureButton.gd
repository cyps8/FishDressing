extends TextureButton

var scaleTween: Tween

@export var isExitButton: bool = false
@export var disableForWeb: bool = false
@export var backButton: bool = false

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

func _Focused():
	if scaleTween:
		scaleTween.stop()
	scaleTween = create_tween()
	scaleTween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
	AudioPlayer.ins.PlaySound(1)
	if !has_focus():
		grab_focus()

func _Pressed():
	if !isExitButton:
		if backButton:
			AudioPlayer.ins.PlaySound(3)
		else:
			AudioPlayer.ins.PlaySound(0)

func _Unfocused():
	if scaleTween:
		scaleTween.stop()
	scaleTween = create_tween()
	scaleTween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)