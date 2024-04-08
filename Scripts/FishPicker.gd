extends CanvasLayer

@export var fishDataList: Array[FishData]

var fishRef: Sprite2D
var fishName: Label

var currentFish = 0

var swapFishTween: Tween

var picked = false

func _ready():
	fishRef = get_parent().get_node("Fish/FishBody")
	fishName = $c/FishName

	var animateTween: Tween = create_tween().set_loops(-1)
	animateTween.tween_property(fishName, "rotation", deg_to_rad(15), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	animateTween.tween_property(fishName, "rotation", deg_to_rad(0), 0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	animateTween.tween_property(fishName, "rotation", deg_to_rad(-15), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	animateTween.tween_property(fishName, "rotation", deg_to_rad(0), 0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

func Pick():
	if picked:
		return
	picked = true
	Game.ins.HideFishPicker()
	Game.ins.ShowHUD()

func SwapFish(direction: int):
	if picked:
		return
	currentFish += direction
	if currentFish < 0:
		currentFish = fishDataList.size() - 1
	if currentFish >= fishDataList.size():
		currentFish = 0
	Fish()

func SetFish(value: int):
	if picked:
		return
	if value < 0:
		value = randi_range(0, fishDataList.size() - 1)
	currentFish = value
	Fish()

func Fish():
	Game.ins.selectedFish = fishDataList[currentFish]
	fishRef.texture = fishDataList[currentFish].texture
	fishName.text = fishDataList[currentFish].name
	if swapFishTween:
		swapFishTween.kill()
	swapFishTween = create_tween()
	fishRef.scale = Vector2(.9, .9)
	fishName.scale = Vector2(1.2, 1.2)
	swapFishTween.tween_property(fishRef, "scale", Vector2(.75, .75), 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	swapFishTween.parallel()
	swapFishTween.tween_property(fishName, "scale", Vector2(1, 1), 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)

func _process(_delta):
	if picked:
		return
	if Game.ins.cogMenu.is_inside_tree():
		return
	if Input.is_action_just_pressed("ui_cancel"):
		BackButton()
		AudioPlayer.ins.PlaySound(3)
	if Input.is_action_just_pressed("ui_left"):
		SwapFish(-1)
	if Input.is_action_just_pressed("ui_right"):
		SwapFish(1)
	if Input.is_action_just_pressed("ui_accept"):
		Pick()

func BackButton():
	if picked:
		return
	picked = true
	Game.ins.ReturnToMenu()