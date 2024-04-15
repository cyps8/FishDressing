extends CanvasLayer

var menuActive: bool = false

var confExit: ConfirmationDialog

func _ready():
	confExit = $ConfExit

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
	if Game.ins.hud.is_inside_tree():
		confExit.visible = true
		var cancel: bool = await ConfirmMenu
		if !cancel:
			return
	Game.ins.ReturnToMenu()

signal ConfirmMenu(val: bool)

func MenuConfirmation(val: bool):
	AudioPlayer.ins.PlaySound(3)
	ConfirmMenu.emit(val)