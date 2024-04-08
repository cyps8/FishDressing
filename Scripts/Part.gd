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

var spawnTween: Tween

var defaultScale: float = 1.0

var currentRedColor: Color = Color.WHITE
var currentGreenColor: Color = Color.WHITE
var currentBlueColor: Color = Color.WHITE

var fakeMousePos: Vector2 = Vector2.ZERO

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
			currentRedColor = red
		if partData.greenChannel:
			material.set_shader_parameter("green_color", green)
			currentGreenColor = green
		if partData.blueChannel:
			material.set_shader_parameter("blue_color", blue)
			currentBlueColor = blue

func SetColorChannel(color: Color, channel: int):
	if partData.colorShader:
		if channel == 0:
			material.set_shader_parameter("red_color", color)
			currentRedColor = color
		elif channel == 1:
			material.set_shader_parameter("green_color", color)
			currentGreenColor = color
		elif channel == 2:
			material.set_shader_parameter("blue_color", color)
			currentBlueColor = color

func UpdateDuplicateRefs(part: Part):
	selectedRef = $Selected
	dangerRef = $Danger

	currentRedColor = part.currentRedColor
	currentGreenColor = part.currentGreenColor
	currentBlueColor = part.currentBlueColor

func GenerateClickMask():
	var data = texture_normal.get_image()
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(data)
	texture_click_mask = bitmap

func Pressed():
	if Input.is_action_just_pressed("Interact") && !Input.is_action_pressed("Control"):
		if !Input.is_action_just_pressed("Interact2"):
			Editor.ins.SelectPart(self)
		else:
			Editor.ins.Duplicate(self)

func Clicked():
	if Input.is_action_pressed("Control") && !Input.is_action_just_released("Interact2"):
		SetControlGroup(!controlGrouped)
		if controlGrouped: 
			ResetMoveValues()
			SpawnAnimation(false)
			AudioPlayer.ins.PlaySound(0)

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
		if !Editor.ins.currentPartGroup.has(self):
			Editor.ins.currentPartGroup.append(self)
	else:
		selectedRef.visible = false
		if Editor.ins.currentPartGroup.has(self):
			Editor.ins.currentPartGroup.erase(self)

func UpdateMovePosition(fake: bool = false):
	if fake:
		position = fakeMousePos - (selectOffset * currentScale).rotated(currentRotation)
	else:
		position = get_viewport().get_mouse_position() - (selectOffset * currentScale).rotated(currentRotation)

func SetScale(value: float, move: bool, fake: bool = false):
	currentScale *= value / scale.x
	scale = Vector2(value, value)
	if move:
		UpdateMovePosition(fake)

func SetRotation(value: float, move: bool, fake: bool = false):
	currentRotation += value - rotation
	rotation = value
	if move:
		UpdateMovePosition(fake)

func SetFakeMouse():
	fakeMousePos = position + (size * scale * 0.5).rotated(rotation)

func ScaleBy(value: float, fake: bool = false):
	if scale.x * value > 0.2 and scale.x * value < 3.0:
		scale *= value
		currentScale *= value
		UpdateMovePosition(fake)

func RotateBy(value: float, fake: bool = false):
	rotation += value
	if rotation > deg_to_rad(360):
		rotation -= deg_to_rad(360)
	if rotation < 0:
		rotation += deg_to_rad(360)
	currentRotation += value
	UpdateMovePosition(fake)

func IsInSafeZone(fishSprite: Sprite2D) -> bool:
	var fBSize = fishSprite.texture.get_size() * fishSprite.scale
	var partPos = position + (size * scale * 0.5).rotated(rotation)
	if partPos.x > fishSprite.position.x - (fBSize.x * 0.5) - 50 and partPos.x < fishSprite.position.x + (fBSize.x * 0.5) + 50 and partPos.y > fishSprite.position.y - (fBSize.y * 0.5) - 50 and partPos.y < fishSprite.position.y + (fBSize.y * 0.5) + 50:
		return true
	return false

func SpawnAnimation(move: bool = true, fake: bool = false):
	if spawnTween && spawnTween.is_running():
		spawnTween.kill()
	else:
		defaultScale = scale.x
	if fake:
		SetFakeMouse()
	SetScale(defaultScale * 1.2, move, fake)
	spawnTween = create_tween()
	spawnTween.tween_method(SetScale.bind(move, fake), defaultScale * 1.2, defaultScale, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func ResetMoveValues(fake: bool = false):
	if fake:
		selectOffset = fakeMousePos - position
	else:
		selectOffset = get_viewport().get_mouse_position() - position
	currentScale = 1.0
	currentRotation = 0.0

func FlipH():
	flip_h = !flip_h
	selectedRef.flip_h = flip_h
	dangerRef.flip_h = flip_h

func FlipV():
	flip_v = !flip_v
	selectedRef.flip_v = flip_v
	dangerRef.flip_v = flip_v

func Delete():
	if deleted:
		return
	SetControlGroup(false)
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
