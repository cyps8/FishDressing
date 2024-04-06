extends TextureButton

class_name Part

var selectOffset: Vector2 = Vector2(0, 0)
var currentScale: float = 1.0
var currentRotation: float = 0.0

var controlGrouped: bool = false

var deleted = false

func SetTexture(tex: Texture2D):
	texture_normal = tex

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

func SetControlGroup(value: bool):
	controlGrouped = value
	if controlGrouped:
		self_modulate = Color(1, 1, 0, 1.0)
	else:
		self_modulate = Color(1, 1, 1, 1.0)

func UpdateMovePosition():
	position = get_viewport().get_mouse_position() - (selectOffset * currentScale).rotated(currentRotation)

func SetScale(value: float):
	scale = Vector2(value, value)
	currentScale = value

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

func Delete():
	if deleted:
		return
	deleted = true
	modulate = Color(1.0, .3, .3, 1.0)
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