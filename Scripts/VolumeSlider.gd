extends HSlider

@export var busName: String = "Master"

var scaleTween: Tween

var holdR: bool = false
var holdL: bool = false
var holdCD: float = 0

func _ready():
	if !OS.has_feature("editor"):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(busName), linear_to_db(0.8))
	value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(busName)))
	value_changed.connect(Callable(_OnChanged))
	mouse_entered.connect(Callable(_Focused))
	mouse_exited.connect(Callable(_Unfocused))
	focus_entered.connect(Callable(_Focused))
	focus_exited.connect(Callable(_Unfocused))

	if pivot_offset == Vector2(0, 0):
		pivot_offset = size/2

func _OnChanged(_value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(busName), linear_to_db(_value))
	AudioPlayer.ins.PlaySound(0, AudioServer.get_bus_index(busName))

func _process(_dt):
	if !has_focus():
		return

	if Input.is_action_just_pressed("ui_left") && !holdR:
		holdL = true
		holdCD = 0.5
	elif Input.is_action_just_pressed("ui_right") && !holdL:
		holdR = true
		holdCD = 0.5
	else:
		holdCD -= _dt

	if !holdL && !holdR:
		return

	if holdL && Input.is_action_just_released("ui_left"):
		holdL = false

	if holdR && Input.is_action_just_released("ui_right"):
		holdR = false

	if holdCD < 0:
		holdCD += 0.075
		if holdL:
			value -= 0.05
		elif holdR:
			value += 0.05

func _Focused():
	if scaleTween:
		scaleTween.stop()
	scaleTween = create_tween()
	scaleTween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
	AudioPlayer.ins.PlaySound(1)

func _Unfocused():
	if scaleTween:
		scaleTween.stop()
	scaleTween = create_tween()
	scaleTween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
