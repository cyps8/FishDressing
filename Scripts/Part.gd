extends TextureButton

class_name Part

func SetTexture(tex: Texture2D):
	texture_normal = tex

func GenerateClickMask():
	var data = texture_normal.get_image()
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(data)
	texture_click_mask = bitmap

func Pressed():
	Editor.ins.SelectPart(self)

func Delete():
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