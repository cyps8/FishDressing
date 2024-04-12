extends Button

class_name DecorButton

var partData: PartData

@export var localMat: Material

var hoverTween: Tween

var textureRef: TextureRect

func _ready():
	mouse_entered.connect(Callable(_Focused))
	mouse_exited.connect(Callable(_Unfocused))
	focus_entered.connect(Callable(_Focused))
	focus_exited.connect(Callable(_Unfocused))

func Setup(data: PartData):
	textureRef = $Texture
	textureRef.pivot_offset = textureRef.size/2

	partData = data
	tooltip_text = partData.name
	textureRef.texture = partData.texture
	if partData.colorShader:
		textureRef.material = localMat
		localMat.set_shader_parameter("red_color", partData.defaultRed)
		localMat.set_shader_parameter("green_color", partData.defaultGreen)
		localMat.set_shader_parameter("blue_color", partData.defaultBlue)

func SetMat(setMat: Material = localMat):
	if partData.colorShader:
		textureRef.material = setMat

func _Focused():
	if Game.ins.hud.mouseGrabbed:
		if has_focus():
			release_focus()
		return
	if disabled:
		return
	if hoverTween:
		hoverTween.stop()
	hoverTween = create_tween()
	hoverTween.tween_property(textureRef, "scale", Vector2(1.2, 1.2), 0.2)
	AudioPlayer.ins.PlaySound(1)
	if !has_focus():
		grab_focus()

func _Unfocused():
	if hoverTween:
		hoverTween.stop()
	hoverTween = create_tween()
	hoverTween.tween_property(textureRef, "scale", Vector2(1.0, 1.0), 0.2)