@icon("res://Assets/Art/Sprites/TestParts/blocks.png")
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

var isGrabbed: bool = true
var animPos: Vector2 = Vector2.ZERO

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

	selectOffset = part.selectOffset
	currentScale = part.currentScale
	currentRotation = part.currentRotation

	if material:
		material = part.material.duplicate(true)

func GenerateClickMask():
	var img = texture_normal.get_image()
	if flip_h:
		img.flip_x()
	if flip_v:
		img.flip_y()
	var data = img
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(data)
	texture_click_mask = bitmap

func Pressed():
	if Input.is_action_just_pressed("Interact"):
		if !Input.is_action_just_pressed("Interact2"):
			if !controlGrouped:
				Editor.ins.SelectPart(self, !Input.is_action_pressed("Control"))
			else:
				if Input.is_action_pressed("Control"):
					SetControlGroup(false)
				else:
					Editor.ins.SelectPart(self)
		else:
			Editor.ins.Duplicate(self)

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

func UpdateMovePosition():
	if !isGrabbed:
		position = fakeMousePos - (selectOffset * currentScale).rotated(currentRotation)
	else:
		position = get_viewport().get_mouse_position() - (selectOffset * currentScale).rotated(currentRotation)

func SetScale(value: float):
	currentScale *= value / scale.x
	scale = Vector2(value, value)
	UpdateMovePosition()

func SetRotation(value: float):
	currentRotation += value - rotation
	rotation = value
	UpdateMovePosition()

func SetFakeMouse():
	fakeMousePos = position + (size * scale * 0.5).rotated(rotation)

func ScaleBy(value: float):
	if scale.x * value > 0.2 and scale.x * value < 3.0:
		scale *= value
		currentScale *= value
		UpdateMovePosition()

func RotateBy(value: float):
	rotation += value
	if rotation > deg_to_rad(360):
		rotation -= deg_to_rad(360)
	if rotation < 0:
		rotation += deg_to_rad(360)
	currentRotation += value
	UpdateMovePosition()

func IsInSafeZone(fishSprite: Sprite2D) -> bool:
	var fBSize = fishSprite.texture.get_size() * fishSprite.scale
	var partPos = position + (size * scale * 0.5).rotated(rotation)
	if partPos.x > fishSprite.position.x - (fBSize.x * 0.5) - 75 and partPos.x < fishSprite.position.x + (fBSize.x * 0.5) + 75 and partPos.y > fishSprite.position.y - (fBSize.y * 0.5) - 75 and partPos.y < fishSprite.position.y + (fBSize.y * 0.5) + 50:
		return true
	return false

func SpawnAnimation():
	animPos = position
	if spawnTween && spawnTween.is_running():
		spawnTween.kill()
	else:
		defaultScale = scale.x
	if !isGrabbed:
		SetFakeMouse()
	SetScale(defaultScale * 1.2)
	spawnTween = create_tween()
	spawnTween.tween_method(SetScale.bind(), defaultScale * 1.2, defaultScale, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func ResetMoveValues(fake: bool = false):
	if spawnTween && spawnTween.is_running():
		scale = Vector2(defaultScale, defaultScale)
		position = animPos
		spawnTween.kill()
	if fake:
		SetFakeMouse()
		selectOffset = fakeMousePos - position
	else:
		selectOffset = get_viewport().get_mouse_position() - position
	currentScale = 1.0
	currentRotation = 0.0

func FlipH():
	flip_h = !flip_h
	selectedRef.flip_h = flip_h
	dangerRef.flip_h = flip_h
	GenerateClickMask()

func FlipV():
	flip_v = !flip_v
	selectedRef.flip_v = flip_v
	dangerRef.flip_v = flip_v
	GenerateClickMask()

func MouseGrabbed(val: bool):
	if val:
		mouse_default_cursor_shape = Control.CURSOR_DRAG
	else:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if isGrabbed == val || deleted || !is_inside_tree():
		return
	isGrabbed = val
	if !controlGrouped:
		ResetMoveValues(true)
	else:
		ResetMoveValues(!val)

var deleteTween: Tween

func Delete():
	if deleted:
		return
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	SetControlGroup(false)
	deleted = true
	SetDanger(true)
	button_down.disconnect(Pressed)
	var ori: Vector2 = position - size * 0.5
	pivot_offset = size * 0.5
	position += (pivot_offset * (scale.x - 1.0))
	position = ori + (position - ori).rotated(rotation)
	deleteTween = create_tween()
	deleteTween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	deleteTween.parallel()
	deleteTween.tween_property(self, "rotation", rotation + deg_to_rad(360), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	deleteTween.tween_callback(get_parent().remove_child.bind(self))
	var grave = func(): Game.ins.hud.partsGraveyard.append(self)
	deleteTween.tween_callback(grave)

func UndoWhileDeleting() -> bool:
	pivot_offset = Vector2(0, 0)
	deleted = false
	if !button_down.is_connected(Pressed):
		button_down.connect(Pressed)
	mouse_filter = Control.MOUSE_FILTER_STOP
	SetDanger(false)
	if deleteTween && deleteTween.is_running():
		deleteTween.kill()
		return true
	return false
	