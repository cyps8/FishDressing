extends CanvasLayer

var menuActive: bool = false

var confExit: ConfirmationDialog

var saveButtonRef: Button
var newSaveButtonRef: Button

func _ready():
	confExit = $ConfExit
	if !Game.ins.demo:
		confExit.add_button("Save & Exit!", false, "SaveAndExit")

	saveButtonRef = %SaveButton
	newSaveButtonRef = %NewSaveButton

func ResumeButton():
	if !menuActive:
		return
	Game.ins.HideCogMenu()

func _process(_delta):
	saveButtonRef.disabled = !Game.ins.editorOpen || SaveMan.ins.activeSave == null || Game.ins.demo
	newSaveButtonRef.disabled = !Game.ins.editorOpen || Game.ins.demo
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
	SaveMan.ins.DeleteBackUp()

func NewSaveButton():
	SaveMan.ins.NewSave()
	SaveMan.ins.DeleteBackUp()

func MenuButton():
	if !menuActive:
		return
	if Game.ins.hud.is_inside_tree() && FileAccess.file_exists("user://backup.backup"):
		confExit.visible = true
		var cancel: bool = await ConfirmMenu
		if !cancel:
			return
	SaveMan.ins.activeSave = null
	Game.ins.ReturnToMenu()

signal ConfirmMenu(val: bool)

func MenuConfirmation(val: bool):
	AudioPlayer.ins.PlaySound(3)
	ConfirmMenu.emit(val)

func SaveAndExit(_action: StringName):
	confExit.visible = false
	if SaveMan.ins.activeSave == null:
		await SaveMan.ins.NewSave()
	else:
		await SaveMan.ins.UpdateSave()
		print("Saved")
	SaveMan.ins.DeleteBackUp()
	ConfirmMenu.emit(true)