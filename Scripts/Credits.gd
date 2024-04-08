extends CanvasLayer

var menuActive: bool = false

func _process(_delta):
	if !menuActive:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		BackButton()
		AudioPlayer.ins.PlaySound(3)

func SetActive(value: bool):
	menuActive = value

func BackButton():
	if !menuActive:
		return
	menuActive = false
	Game.ins.HideCredits()