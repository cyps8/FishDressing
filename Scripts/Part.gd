extends TextureButton

class_name Part

var selectOffset: Vector2 = Vector2(0, 0)
var currentScale: float = 1.0
var currentRotation: float = 0.0

var controlGrouped: bool = false

var deleted = false

var partData: PartData

var inDanger: bool = false

@export var colorShader: Material

@export var selectedRef: TextureRect

@export var dangerRef: TextureRect

func SetTexture(tex: Texture2D):
	texture_normal = tex
	selectedRef.texture = tex
	dangerRef.texture = tex
	if partData.colorShader:
		material = colorShader
	selectedRef.visible = false
	dangerRef.visible = false

func SetColors(red: Color, green: Color = Color.WHITE, blue: Color = Color.WHITE):
	if partData.colorShader:
		if partData.redChannel:
			material.set_shader_parameter("red_color", red)
		if partData.greenChannel:
			material.set_shader_parameter("green_color", green)
		if partData.blueChannel:
			material.set_shader_parameter("blue_color", blue)

func UpdateDuplicateRefs():
	selectedRef = $Selected
	dangerRef = $Danger

func GenerateClickMask():
	var data = texture_normal.get_image()
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(data)
	texture_click_mask = bitmap

func Pressed():
	if Input.is_action_just_pressed("Interact"):
		if !Input.is_action_just_pressed("Interact2"):
			Editor.ins.SelectPart(self)
		else:
			Editor.ins.Duplicate(self)

func Clicked():
	if Input.is_action_pressed("Control") && !Input.is_action_just_released("Interact2"):
		SetControlGroup(!controlGrouped)

func SetDanger(value: bool):
	if inDanger == value:
		return
	inDanger = value
	if inDanger:
		dangerRef.visible = true
	else:
		dangerRef.visible = false

func SetControlGroup(value: bool):
	if controlGrouped == value:
		return
	controlGrouped = value
	if controlGrouped:
		selectedRef.visible = true
	else:
		selectedRef.visible = false

func UpdateMovePosition():
	position = get_viewport().get_mouse_position() - (selectOffset * currentScale).rotated(currentRotation)

func SetScale(value: float):
	currentScale *= value / scale.x
	scale = Vector2(value, value)

func ScaleBy(value: float):
	if scale.x * value > 0.2 and scale.x * value < 5.0:
		scale *= value
		currentScale *= value

func IsInSafeZone(fishSprite: Sprite2D) -> bool:
	var fBSize = fishSprite.texture.get_size() * fishSprite.scale
	var partPos = position + (size * scale * 0.5).rotated(rotation)
	if partPos.x > fishSprite.position.x - (fBSize.x * 0.5) - 50 and partPos.x < fishSprite.position.x + (fBSize.x * 0.5) + 50 and partPos.y > fishSprite.position.y - (fBSize.y * 0.5) - 50 and partPos.y < fishSprite.position.y + (fBSize.y * 0.5) + 50:
		return true
	return false

func SpawnAnimation():
	var defaultScale: float = scale.x
	SetScale(defaultScale * 1.2)
	var spawnTween = create_tween()
	spawnTween.tween_method(SetScale, defaultScale * 1.2, defaultScale, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func Delete():
	if deleted:
		return
	deleted = true
	SetDanger(true)
	button_down.disconnect(Pressed)
	var ori: Vector2 = position - size * 0.5
	pivot_offset = size * 0.5
	position += (pivot_offset * (scale.x - 1.0))
	position = ori + (position - ori).rotated(rotation)
	var deleteTween: Tween = create_tween()
	deleteTween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	deleteTween.parallel()
	deleteTween.tween_property(self, "rotation", rotation + deg_to_rad(360), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	deleteTween.tween_callback(queue_free)
