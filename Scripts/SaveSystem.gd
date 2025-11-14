extends CanvasLayer

var menuActive: bool = false

@export var saveButton: PackedScene

var savesGrid: GridContainer
var noSavesText: Label
var loadButton: Button
var deleteButton: Button

var buttonGroup: ButtonGroup

var saveSelected: int = -1

var buttonSelected: Button

func SetActive(value: bool):
	menuActive = value

func BackButton():
	if !menuActive:
		return
	menuActive = false
	Game.ins.HideSaveSystem()

func _process(_delta):
	deleteButton.disabled = saveSelected == -1
	loadButton.disabled = saveSelected == -1
	noSavesText.visible = SaveMan.ins.saves.size() == 0
	if !menuActive:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		BackButton()
		AudioPlayer.ins.PlaySound(3)

func _ready():
	if Game.ins.demo:
		return
	noSavesText = %NoSaves
	savesGrid = %Saves
	loadButton = %Load
	deleteButton = %Delete
	buttonGroup = ButtonGroup.new()
	buttonGroup.allow_unpress = true

func Update():
	for button in savesGrid.get_children():
		button.queue_free()
	for i in SaveMan.ins.saves.size():
		var button = saveButton.instantiate()
		savesGrid.add_child(button)
		button.button_group = buttonGroup
		button.toggled.connect(Callable(self, "SaveSelected").bind(i, button))
		button.save = SaveMan.ins.saves[i]
		button.Update()
	var sortedNodes = savesGrid.get_children()
	sortedNodes.sort_custom(Callable(func(a, b): return a.save.lastModified > b.save.lastModified))
	for node in savesGrid.get_children():
		savesGrid.remove_child(node)
	for node in sortedNodes:
		savesGrid.add_child(node)

func SaveSelected(on: bool, id: int, button: Button):
	if on:
		saveSelected = id
		buttonSelected = button
	elif !on && saveSelected == id:
		saveSelected = -1
		buttonSelected = null
	
func LoadPressed():
	if saveSelected == -1:
		return
	SaveMan.ins.LoadSave(buttonSelected.save)
	BackButton()
	saveSelected = -1

func DeletePressed():
	if saveSelected == -1:
		return
	SaveMan.ins.DeleteSave(saveSelected) 
	Update()
	saveSelected = -1
