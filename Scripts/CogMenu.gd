extends CanvasLayer

var menuActive: bool = false

var confExit: ConfirmationDialog

var saveButtonRef: Button
var newSaveButtonRef: Button

func _ready():
	confExit = $ConfExit

	saveButtonRef = %SaveButton
	newSaveButtonRef = %NewSaveButton

func ResumeButton():
	if !menuActive:
		return
	Game.ins.HideCogMenu()

func _process(_delta):
	saveButtonRef.disabled = !Game.ins.editorOpen || SaveMan.ins.activeSave == null
	newSaveButtonRef.disabled = !Game.ins.editorOpen
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

func LoadButton():
	if !menuActive:
		return
	Game.ins.ShowSaveSystem()

func SaveButton():
	SaveMan.ins.UpdateSave()

func NewSaveButton():
	SaveMan.ins.NewSave()

func MenuButton():
	if !menuActive:
		return
	SaveMan.ins.activeSave = null
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