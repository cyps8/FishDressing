extends CanvasLayer

var menuActive: bool = false

func ResumeButton():
	if !menuActive:
		return
	Game.ins.HideCogMenu()

func _process(_delta):
	if !menuActive:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		ResumeButton()
		AudioPlayer.ins.PlaySound(3)

func SetActive(value: bool):
	menuActive = value

func SettingsButton():
	if !menuActive:
		return
	Game.ins.ShowSettings()

func MenuButton():
	if !menuActive:
		return
	Game.ins.ReturnToMenu()