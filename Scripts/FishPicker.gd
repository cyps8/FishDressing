extends CanvasLayer

@export var fishDataList: Array[FishData]

var fishRef: Sprite2D

var currentFish = 0

var swapFishTween: Tween

func _ready():
	fishRef = get_parent().get_node("Fish/FishBody")

func Pick():
	Game.ins.HideFishPicker()
	Game.ins.ShowHUD()

func SwapFish(direction: int):
	currentFish += direction
	if currentFish < 0:
		currentFish = fishDataList.size() - 1
	if currentFish >= fishDataList.size():
		currentFish = 0
	fishRef.texture = fishDataList[currentFish].texture

	if swapFishTween:
		swapFishTween.kill()
	swapFishTween = create_tween()
	fishRef.scale = Vector2(.9, .9)
	swapFishTween.tween_property(fishRef, "scale", Vector2(.75, .75), 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	AudioPlayer.ins.PlaySound(0)

func _process(_delta):
	if Input.is_action_just_pressed("ui_left"):
		SwapFish(-1)
	if Input.is_action_just_pressed("ui_right"):
		SwapFish(1)
	if Input.is_action_just_pressed("ui_accept"):
		Pick()