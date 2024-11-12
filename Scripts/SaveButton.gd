extends Button

class_name SaveButton

var save: Save

var iconWobbleTween: Tween
var nameWobbleTween: Tween

func _ready():
    $Name.pivot_offset = $Name.size * 0.5
    toggled.connect(Callable(SetWobble))

func Update():
    $Fish.texture = save.saveIcon
    $Name.text = save.name
    var widthScale: float = 180.0 / save.saveIcon.get_width() as float
    var heightScale: float = 250.0 / save.saveIcon.get_height() as float

    if widthScale < heightScale:
        $Fish.scale = Vector2(widthScale, widthScale)
    else:
        $Fish.scale = Vector2(heightScale, heightScale)
    
func SetWobble(wobble: bool):
    if wobble:
        if iconWobbleTween && iconWobbleTween.is_running():
            iconWobbleTween.kill()
        iconWobbleTween = create_tween().set_loops(-1)
        iconWobbleTween.tween_property($Fish, "rotation", deg_to_rad(10), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
        iconWobbleTween.tween_property($Fish, "rotation", deg_to_rad(0), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
        iconWobbleTween.tween_property($Fish, "rotation", deg_to_rad(-10), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
        iconWobbleTween.tween_property($Fish, "rotation", deg_to_rad(0), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

        if nameWobbleTween && nameWobbleTween.is_running():
            nameWobbleTween.kill()
        nameWobbleTween = create_tween().set_loops(-1)
        nameWobbleTween.tween_property($Name, "rotation", deg_to_rad(-15), 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
        nameWobbleTween.tween_property($Name, "rotation", deg_to_rad(0), 0.35).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
        nameWobbleTween.tween_property($Name, "rotation", deg_to_rad(15), 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
        nameWobbleTween.tween_property($Name, "rotation", deg_to_rad(0), 0.35).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
    else:
        if iconWobbleTween && iconWobbleTween.is_running():
            iconWobbleTween.kill()
        iconWobbleTween = create_tween()
        iconWobbleTween.tween_property($Fish, "rotation", deg_to_rad(0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
        if nameWobbleTween && nameWobbleTween.is_running():
            nameWobbleTween.kill()
        nameWobbleTween = create_tween()
        nameWobbleTween.tween_property($Name, "rotation", deg_to_rad(0), 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)