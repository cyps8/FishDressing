extends CanvasLayer

class_name Editor

static var ins: Editor

@export var partIns: PackedScene

@export var decorButtonIns: PackedScene

@export var partDataList: Array[PartData]

@export var testPartDataList: Array[PartData]

var decorButtons: Array[DecorButton] = []

var currentPartGroup: Array[Part] = []

var mouseGrabbed: bool = false

var fishRef: CanvasGroup

@export var colorMaterial: Material

var pickedColorR: Color = Color.CYAN
var pickedColorG: Color = Color.YELLOW
var pickedColorB: Color = Color.MAGENTA

var rPickerRef: ColorPickerButton
var gPickerRef: ColorPickerButton
var bPickerRef: ColorPickerButton

var scrollRef: ScrollContainer

var overrideColours: bool = false
var overrideButton: CheckButton

var showTestParts: bool = false
var layerLimit: int = 1

var currentCategory: int = 0

var categories: TabBar

var nameEdit: LineEdit
var nameType: Label

var texting: bool = false

var clickedOut: TextureButton

var fileDialog: FileDialog
var stickerCap: SubViewport
var confCancel: ConfirmationDialog

signal MouseGrabbed(val: bool)

func _init():
	ins = self

func EditorOpened():
	nameEdit.text = ""
	if Game.ins.selectedFish:
		nameType.text = "The " + Game.ins.selectedFish.name + "!"

	overrideButton.button_pressed = false
	overrideColours = false

	currentCategory = 0
	categories.current_tab = 0
	UpdateTags()
	scrollRef.scroll_vertical = 0

	rPickerRef.color = Color.CYAN
	gPickerRef.color = Color.YELLOW
	bPickerRef.color = Color.MAGENTA
	pickedColorR = rPickerRef.color
	pickedColorG = gPickerRef.color
	pickedColorB = bPickerRef.color
	colorMaterial.set_shader_parameter("red_color", pickedColorR)
	colorMaterial.set_shader_parameter("green_color", pickedColorG)
	colorMaterial.set_shader_parameter("blue_color", pickedColorB)

	currentState = SaveState.new()

	undoStates.clear()
	redoStates.clear()

func _ready():
	overrideButton = %OverrideDefault
	rPickerRef = %ColorR
	gPickerRef = %ColorG
	bPickerRef = %ColorB
	categories = %Categories

	scrollRef = %Scroll

	nameEdit = %EnterName
	nameType = %FishType

	clickedOut = %ClickedOut

	fileDialog = $FileDialog
	stickerCap = $StickerCapture
	confCancel = $ConfCancel

	ResetEditor()

	partDataList.append_array(testPartDataList)

	for i in partDataList.size():
		var newButton: DecorButton = decorButtonIns.instantiate()
		newButton.Setup(partDataList[i])
		newButton.connect("button_down", Callable(self, "CreateNewDecor").bind(i))
		decorButtons.append(newButton)
		%Decors.add_child(newButton)

	fishRef = get_parent().get_node("Fish")

func InText(value: bool):
	texting = value

var creatingNew: bool = false

func InstaCreateNewDecor(info: DecorInfo, belowLayer: int = 0):
	var newDecor = partIns.instantiate() as Part
	newDecor.id = info.id
	newDecor.partData = partDataList[info.id]
	MouseGrabbed.connect(newDecor.MouseGrabbed)
	newDecor.SetTexture(partDataList[info.id].texture)
	newDecor.GenerateClickMask()
	newDecor.SetColors(info.colourR, info.colourG, info.colourB)
	newDecor.position = info.position
	newDecor.rotation = info.rotation
	newDecor.scale = Vector2(info.scale, info.scale)
	newDecor.flip_h = info.flippedH
	newDecor.flip_v = info.flippedV
	fishRef.add_child(newDecor)
	if info.belowFish:
		fishRef.move_child(newDecor, belowLayer)
	newDecor.ResetMoveValues(true)

func CreateNewDecor(id: int = 0):
	creatingNew = true
	var newDecor = partIns.instantiate() as Part
	newDecor.id = id
	newDecor.partData = partDataList[id]
	MouseGrabbed.connect(newDecor.MouseGrabbed)
	newDecor.SetTexture(partDataList[id].texture)
	newDecor.GenerateClickMask()
	if overrideColours:
		newDecor.SetColors(pickedColorR, pickedColorG, pickedColorB)
	else:
		newDecor.SetColors(partDataList[id].defaultRed, partDataList[id].defaultGreen, partDataList[id].defaultBlue)
	var mousePos = get_viewport().get_mouse_position()
	newDecor.position = mousePos
	fishRef.add_child(newDecor)
	newDecor.selectOffset = newDecor.size / 2
	ClearControlGroup()
	newDecor.SetControlGroup(true)
	SetMouseGrabbed(true)
	newDecor.SpawnAnimation(true)
	AudioPlayer.ins.PlaySound(0)

func _enter_tree():
	UpdateTags()

func CategoryChanged(value: int):
	if currentCategory == value:
		return
	currentCategory = value
	UpdateTags()

func UpdateTags():
	if currentCategory == 0:
		for decor in decorButtons:
			if decor.partData.tags & PartData.Tag.TEST != 0:
				decor.visible = showTestParts
			else:
				decor.visible = true
		return
	else:
		var tagToCompare: PartData.Tag = PartData.Tag.HEAD
		match currentCategory:
			1:
				tagToCompare = PartData.Tag.HEAD
			2:
				tagToCompare = PartData.Tag.UPPER
			3:
				tagToCompare = PartData.Tag.LOWER
			4:
				tagToCompare = PartData.Tag.ACCESSORY
		for decor in decorButtons:
			if decor.partData.tags & tagToCompare != 0:
				if decor.partData.tags & PartData.Tag.TEST != 0:
					decor.visible = showTestParts
				else:
					decor.visible = true
			else:
				decor.visible = false

func ResetEditor():
	SetMouseGrabbed(false)

var prevPositions: Array[Vector2] = []
var prevRotations: Array[float] = []
var prevScales: Array[float] = []
var prevIndexes: Array[int] = []
var prevFlipHs: Array[bool] = []
var prevFlipVs: Array[bool] = []

var prevDelPositions: Array[Vector2] = []
var prevDelRotations: Array[float] = []
var prevDelScales: Array[float] = []
var prevDelIndexes: Array[int] = []
var prevDelFlipHs: Array[bool] = []
var prevDelFlipVs: Array[bool] = []

var currentState: SaveState
var undoStates: Array[SaveState] = []
var redoStates: Array[SaveState] = []

var deletingParts: Array[Part] = []

func SetMouseGrabbed(value: bool):
	if mouseGrabbed == value:
		return
	MouseGrabbed.emit(value)
	mouseGrabbed = value
	if mouseGrabbed:
		if creatingNew:
			return
		prevPositions.clear()
		prevRotations.clear()
		prevScales.clear()
		prevIndexes.clear()
		prevFlipHs.clear()
		prevFlipVs.clear()
		for part in currentPartGroup:
			prevPositions.append(part.position)
			prevRotations.append(part.rotation)
			prevScales.append(part.scale.x)
			prevIndexes.append(part.get_index())
			prevFlipHs.append(part.flip_h)
			prevFlipVs.append(part.flip_v)
	if !mouseGrabbed:
		if creatingNew:
			if currentPartGroup.size() > 0:
				CreateAction("Create")
			creatingNew = false
		elif duplicatingNew:
			if currentPartGroup.size() > 0:
				CreateAction("Duplicate")
			duplicatingNew = false
		else:
			MouseAction()

func Undo():
	var undoState: SaveState = undoStates.pop_front()
	redoStates.insert(0, currentState)
	LoadState(undoState)

	ClearControlGroup()
	Log("Undo")

func Redo():
	var redoState: SaveState = redoStates.pop_front()
	InsertUndoState(currentState)
	LoadState(redoState)
	
	ClearControlGroup()
	Log("Redo")

func AddAction(newAction: Array[Action]):
	InsertUndoState(currentState)
	SaveCurrentState()
	LogAction("Action: ", newAction)

func LoadState(state: SaveState):
	DeleteAll()
	var i: int = 0
	for part in state.parts:
		InstaCreateNewDecor(part, i)
		i += 1
	currentState = state

func SaveCurrentState():
	var bodyPos: int = fishRef.get_node("FishBody").get_index()

	currentState = SaveState.new()

	for part in fishRef.get_children():
		if part.get_index() == bodyPos || part.deleted:
			continue
		var newInfo = DecorInfo.new(part.id, part.position, part.rotation, part.scale.x, part.flip_h, part.flip_v, part.currentRedColor, part.currentGreenColor, part.currentBlueColor, (part.get_index() < bodyPos))
		currentState.parts.append(newInfo)

func InsertUndoState(state: SaveState):
	undoStates.insert(0, state)
	if undoStates.size() > 50:
		undoStates.pop_back()

func Log(message: String):
	Game.ins.toolbar.AddActionLabel(message)

func LogAction(message: String, actionsToLog: Array[Action]):
	var actionNames: Array[String] = []
	for action in actionsToLog:
		actionNames.append(action.name)
	message += ", ".join(actionNames)
	Game.ins.toolbar.AddActionLabel(message)

func CreateAction(actName: String):
	redoStates.clear()
	var currentAction: Array[Action] = []
	var createAction: ActionCreate = ActionCreate.new()
	createAction.Create(currentPartGroup)
	createAction.name = actName
	currentAction.append(createAction)

	AddAction(currentAction)

func MouseAction():
	if currentPartGroup.size() == 0 && deletingParts.size() == 0:
		return
	redoStates.clear()
	var currentAction: Array[Action] = []
	if currentPartGroup.size() > 0:
		var moveAction: ActionMove = ActionMove.new()
		moveAction.Create(currentPartGroup, prevPositions)
		moveAction.name = "Move"
		currentAction.append(moveAction)
		if currentPartGroup[0].rotation != prevRotations[0]:
			var rotateAction: ActionRotate = ActionRotate.new()
			rotateAction.Create(currentPartGroup, prevRotations)
			rotateAction.name = "Rotate"
			currentAction.append(rotateAction)
		if currentPartGroup[0].scale.x != prevScales[0]:
			var scaleAction: ActionScale = ActionScale.new()
			scaleAction.Create(currentPartGroup, prevScales)
			scaleAction.name = "Scale"
			currentAction.append(scaleAction)
		if LayerMismatch():
			var layerAction: ActionLayer = ActionLayer.new()
			layerAction.Create(currentPartGroup, prevIndexes)
			layerAction.name = "Layer"
			currentAction.append(layerAction)
		if currentPartGroup[0].flip_h != prevFlipHs[0]:
			var flipHAction: ActionFlipH = ActionFlipH.new()
			flipHAction.Create(currentPartGroup, prevFlipHs)
			flipHAction.name = "FlipH"
			currentAction.append(flipHAction)
		if currentPartGroup[0].flip_v != prevFlipVs[0]:
			var flipVAction: ActionFlipV = ActionFlipV.new()
			flipVAction.Create(currentPartGroup, prevFlipVs)
			flipVAction.name = "FlipV"
			currentAction.append(flipVAction)
	if deletingParts.size() > 0:
		var deleteAction: ActionDelete = ActionDelete.new()
		deleteAction.Create(deletingParts, prevDelPositions, prevDelIndexes, prevDelRotations, prevDelScales, prevDelFlipHs, prevDelFlipVs)
		deleteAction.name = "Delete"
		currentAction.append(deleteAction)
		deletingParts.clear()
	AddAction(currentAction)

func DeleteAction():
	redoStates.clear()
	var currentAction: Array[Action] = []
	var deleteAction: ActionDelete = ActionDelete.new()
	deleteAction.Create(currentPartGroup, prevPositions, prevIndexes, prevRotations, prevScales, prevFlipHs, prevFlipVs)
	deleteAction.name = "Delete"
	currentAction.append(deleteAction)
	AddAction(currentAction)

var keyRotating: bool = false

func RotateAction():
	if creatingNew: return
	redoStates.clear()
	var currentAction: Array[Action] = []
	var positionAction: ActionMove = ActionMove.new()
	positionAction.Create(currentPartGroup, prevPositions)
	positionAction.name = "Move"
	currentAction.append(positionAction)
	var rotateAction: ActionRotate = ActionRotate.new()
	rotateAction.Create(currentPartGroup, prevRotations)
	rotateAction.name = "Rotate"
	currentAction.append(rotateAction)
	AddAction(currentAction)

var keyScaling: bool = false

func ScaleAction():
	if creatingNew: return
	redoStates.clear()
	var currentAction: Array[Action] = []
	var positionAction: ActionMove = ActionMove.new()
	positionAction.Create(currentPartGroup, prevPositions)
	positionAction.name = "Move"
	currentAction.append(positionAction)
	var scaleAction: ActionScale = ActionScale.new()
	scaleAction.Create(currentPartGroup, prevScales)
	scaleAction.name = "Scale"
	currentAction.append(scaleAction)
	AddAction(currentAction)

func LayerAction():
	if mouseGrabbed || !LayerMismatch():
		return
	redoStates.clear()
	var currentAction: Array[Action] = []
	var layerAction: ActionLayer = ActionLayer.new()
	layerAction.Create(currentPartGroup, prevIndexes)
	layerAction.name = "Layer"
	currentAction.append(layerAction)
	AddAction(currentAction)

func FlipHAction():
	if creatingNew || mouseGrabbed: return
	redoStates.clear()
	var currentAction: Array[Action] = []
	var flipHAction: ActionFlipH = ActionFlipH.new()
	flipHAction.Create(currentPartGroup, prevFlipHs)
	flipHAction.name = "FlipH"
	currentAction.append(flipHAction)
	AddAction(currentAction)

func FlipVAction():
	if creatingNew || mouseGrabbed: return
	redoStates.clear()
	var currentAction: Array[Action] = []
	var flipVAction: ActionFlipV = ActionFlipV.new()
	flipVAction.Create(currentPartGroup, prevFlipVs)
	flipVAction.name = "FlipV"
	currentAction.append(flipVAction)
	AddAction(currentAction)

func ColorChangeAction():
	redoStates.clear()
	var currentAction: Array[Action] = []
	var action: Action = Action.new()
	action.name = "Color"
	currentAction.append(action)
	AddAction(currentAction)

func LayerMismatch() -> bool:
	for i in currentPartGroup.size():
		if currentPartGroup[i].get_index() != prevIndexes[i]:
			return true
	return false

func MoveToDelete(part: Part):
	deletingParts.append(part)
	prevDelPositions.append(prevPositions[currentPartGroup.find(part)])
	prevDelRotations.append(prevRotations[currentPartGroup.find(part)])
	prevDelScales.append(prevScales[currentPartGroup.find(part)])
	prevDelIndexes.append(prevIndexes[currentPartGroup.find(part)])
	prevDelFlipHs.append(prevFlipHs[currentPartGroup.find(part)])
	prevDelFlipVs.append(prevFlipVs[currentPartGroup.find(part)])
	prevPositions.remove_at(currentPartGroup.find(part))
	prevRotations.remove_at(currentPartGroup.find(part))
	prevScales.remove_at(currentPartGroup.find(part))
	prevIndexes.remove_at(currentPartGroup.find(part))
	prevFlipHs.remove_at(currentPartGroup.find(part))
	prevFlipVs.remove_at(currentPartGroup.find(part))
	part.SetControlGroup(false)
	
func _process(_delta):
	if fileDialog.visible:
		return
	if confCancel.visible:
		return
	if Game.ins.cogMenu.is_inside_tree():
		return
	if Input.is_action_just_pressed("ui_cancel") && !mouseGrabbed:
		Game.ins.ShowCogMenu()
		return
	if texting:
		return
	if Input.is_action_just_released("Interact"):
		if currentPartGroup.size() > 0:
			var partsToDelete: Array[Part] = []
			var i: int = 0
			while i < currentPartGroup.size():
				if !currentPartGroup[i].IsInSafeZone(fishRef.get_node("FishBody") as Sprite2D):
					partsToDelete.append(currentPartGroup[i])
					if !creatingNew:
						MoveToDelete(currentPartGroup[i])
						i -= 1
				i += 1
			if partsToDelete.size() > 0:
				AudioPlayer.ins.PlaySound(5)
			while partsToDelete.size() > 0:
				partsToDelete[0].Delete()
				partsToDelete.remove_at(0)
			if mouseGrabbed:
				var soundsPlayed: Array[int] = []
				for part in currentPartGroup:
					var soundId: int = part.partData.materialSound
					if !soundsPlayed.has(soundId):
						AudioPlayer.ins.PlayMatSound(soundId, AudioPlayer.SoundType.SFX, 1.3, randf() * 0.4 + 0.8)
						soundsPlayed.append(soundId)
		SetMouseGrabbed(false)
	if Input.is_action_just_pressed("Undo") && undoStates.size() > 0 && !mouseGrabbed:
		Undo()
	if Input.is_action_just_pressed("Redo") && redoStates.size() > 0 && !mouseGrabbed:
		Redo()
	if Input.is_action_just_pressed("RotateLeft") && Input.is_action_pressed("Control") && !mouseGrabbed:
		SelectAll()
	if currentPartGroup.size() > 0:
		if Input.is_action_just_released("Interact"):
			for part in currentPartGroup:
				part.SetFakeMouse()
		if Input.is_action_just_pressed("RotateRight") && Input.is_action_pressed("Control") && !mouseGrabbed:
			Duplicate()
		if Input.is_action_just_pressed("Delete")  && !Input.is_action_pressed("Control"):
			if mouseGrabbed && !creatingNew:
				DeleteAction()
			DeleteAllSelected()
			SetMouseGrabbed(false)
			return
		if Input.is_action_just_pressed("Flip") && !Input.is_action_pressed("Control"):
			if Input.is_action_pressed("Shift"):
				FlipV()
			else:
				FlipH()
		if Input.is_action_pressed("ScaleUp") && !Input.is_action_pressed("Control") && !keyRotating:
			if !keyScaling && !mouseGrabbed:
				ResetScale()
			keyScaling = true
			if Input.is_action_pressed("Shift"):
				ChangeScale(1.05)
			else:
				ChangeScale(1.01)
		elif Input.is_action_pressed("ScaleDown") && !Input.is_action_pressed("Control") && !keyRotating:
			if !keyScaling && !mouseGrabbed:
				ResetScale()
			keyScaling = true
			if Input.is_action_pressed("Shift"):
				ChangeScale(0.95)
			else:
				ChangeScale(0.99)
		else:
			if keyScaling && !mouseGrabbed:
				ScaleAction()
			keyScaling = false
		if Input.is_action_pressed("RotateLeft") && !Input.is_action_pressed("Control") && !keyScaling:
			if !keyRotating && !mouseGrabbed:
				ResetRotation()
			keyRotating = true
			if Input.is_action_pressed("Shift"):
				RotatePart(-0.05)
			else:
				RotatePart(-0.01)
		elif Input.is_action_pressed("RotateRight") && !Input.is_action_pressed("Control") && !keyScaling:
			if !keyRotating && !mouseGrabbed:
				ResetRotation()
			keyRotating = true
			if Input.is_action_pressed("Shift"):
				RotatePart(0.05)
			else:
				RotatePart(0.01)
		else:
			if keyRotating && !mouseGrabbed:
				RotateAction()
			keyRotating = false
		if Input.is_action_just_pressed("MoveUp") && !Input.is_action_pressed("Control"):
			if Input.is_action_pressed("Shift"):
				MoveToTop()
			else:
				MoveUp()
		elif Input.is_action_just_pressed("MoveDown") && !Input.is_action_pressed("Control"):
			if Input.is_action_pressed("Shift"):
				MoveToBottom()
			else:
				MoveDown()
		if Input.is_action_pressed("Interact") && mouseGrabbed:
			for part in currentPartGroup:
				UpdateSafeColour(part)
			if Input.is_action_just_released("ScrollDown"):
				if Input.is_action_pressed("Shift"):
					RotatePart(0.05)
				else:
					ChangeScale(0.9)
			elif Input.is_action_just_released("ScrollUp"):
				if Input.is_action_pressed("Shift"):
					RotatePart(-0.05)
				else:
					ChangeScale(1.1)
			for part in currentPartGroup:
				part.UpdateMovePosition()

func ResetScale():
	prevPositions.clear()
	prevScales.clear()
	for part in currentPartGroup:
		prevPositions.append(part.position)
		prevScales.append(part.scale.x)

func ResetRotation():
	prevPositions.clear()
	prevRotations.clear()
	for part in currentPartGroup:
		prevPositions.append(part.position)
		prevRotations.append(part.rotation)

func ClickedOut():
	ClearControlGroup()

func ClearControlGroup():
	while currentPartGroup.size() > 0:
		currentPartGroup[0].SetControlGroup(false)

func UpdateSafeColour(part: Part):
	if part.IsInSafeZone(fishRef.get_node("FishBody") as Sprite2D):
		part.SetDanger(false)
	else:
		part.SetDanger(true)

func ResetSelectedMoveValues():
	for part in currentPartGroup:
		part.ResetMoveValues()

func RotatePart(amount: float):
	for part in currentPartGroup:
		part.RotateBy(amount)

func SetRotation(value: float):
	for part in currentPartGroup:
		part.SetRotation(value)

func SetScale(value: float):
	for part in currentPartGroup:
		part.SetScale(value)

func ChangeScale(value: float):
	for part in currentPartGroup:
		part.ScaleBy(value)

func SelectPart(selectedPart: Part, clearGroup: bool = true, anim = true):
	if !currentPartGroup.has(selectedPart):
		if clearGroup:
			ClearControlGroup()
		selectedPart.SetControlGroup(true)
	SetMouseGrabbed(true)
	if anim:
		for part in currentPartGroup:
			part.SpawnAnimation()
		if Game.ins.cursorTeeth:
			AudioPlayer.ins.PlayFishSound(3, AudioPlayer.SoundType.SFX, 1.0, (randf() * 0.4) + 1.5)
		else:
			AudioPlayer.ins.PlaySound(0)

func GetAll(control: bool = false) -> Array[Part]:
	var allParts: Array[Part] = []
	for part in fishRef.get_children():
		if part.is_in_group("Part") && !part.deleted:
			allParts.append(part)
			if control && !part.controlGrouped:
				part.SetControlGroup(true)
	return allParts

func SelectAll():
	var allInGroup = true
	for part in GetAll():
		if !part.controlGrouped:
			part.SetControlGroup(true)
			part.SpawnAnimation()
			allInGroup = false
	if allInGroup:
		ClearControlGroup()
	else:
		AudioPlayer.ins.PlaySound(0)

var duplicatingNew: bool = false

func Duplicate(selectedPart: Part = null):
	if selectedPart:
		SelectPart(selectedPart, true, false)
	var dupedParts: Array[Part] = []
	SortCurrentPartGroupLesser()
	for part in currentPartGroup:
		var dupedPart: Part = part.duplicate()
		dupedPart.id = part.id
		dupedPart.partData = part.partData
		dupedPart.UpdateDuplicateRefs(part)
		fishRef.add_child(dupedPart)
		dupedParts.append(dupedPart)
	ClearControlGroup()
	for part in dupedParts:
		part.SetControlGroup(true)
		MouseGrabbed.connect(part.MouseGrabbed)
		part.MouseGrabbed(mouseGrabbed)
		part.SpawnAnimation()
	if selectedPart != null:
		SetMouseGrabbed(true)
		duplicatingNew = true
	else:
		CreateAction("Duplicate")
	if selectedPart != null:
		if Game.ins.cursorTeeth:
			AudioPlayer.ins.PlayFishSound(3, AudioPlayer.SoundType.SFX, 1.0,(randf() * 0.4) + 1.5)
		else:
			AudioPlayer.ins.PlaySound(0)
	else:
		AudioPlayer.ins.PlaySound(0)

func MoveUp():
	SortCurrentPartGroupGreater()
	ResetIndexes()
	for part in currentPartGroup:
		var index = part.get_index()
		if index < fishRef.get_child_count():
			fishRef.move_child(part, index + 1)
	LayerAction()

func MoveDown():
	SortCurrentPartGroupLesser()
	ResetIndexes()
	for i in currentPartGroup.size():
		var index = currentPartGroup[i].get_index()
		if index > layerLimit && (i - currentPartGroup.size()) != (index - fishRef.get_child_count() - 1):
			fishRef.move_child(currentPartGroup[i], index - 1)
	LayerAction()

func MoveToTop():
	SortCurrentPartGroupLesser()
	ResetIndexes()
	for part in currentPartGroup:
		fishRef.move_child(part, fishRef.get_child_count() - 1)
	LayerAction()

func MoveToBottom():
	SortCurrentPartGroupGreater()
	ResetIndexes()
	for part in currentPartGroup:
		fishRef.move_child(part, layerLimit)
	LayerAction()

func ResetIndexes():
	if mouseGrabbed:
		return
	prevIndexes.clear()
	for part in currentPartGroup:
		prevIndexes.append(part.get_index())

func SetCanGoBehind(val: bool):
	if val:
		layerLimit = 0
	else:
		layerLimit = 1
		if fishRef.get_node("FishBody").get_index() != 0:
			undoStates.clear()
			redoStates.clear()
		fishRef.move_child(fishRef.get_node("FishBody"), 0)
		

func ColorPickChanged(newColor: Color, val: int = 1):
	match val:
		1:
			pickedColorR = newColor
			colorMaterial.set_shader_parameter("red_color", newColor)
		2:
			pickedColorG = newColor
			colorMaterial.set_shader_parameter("green_color", newColor)
		3:
			pickedColorB = newColor
			colorMaterial.set_shader_parameter("blue_color", newColor)

func DeleteAllSelected():
	if !mouseGrabbed:
		ResetForDelete()
		DeleteAction()
	while currentPartGroup.size() > 0:
		currentPartGroup[0].Delete()
	AudioPlayer.ins.PlaySound(5)

func DeleteAll(insta: bool = true):
	var toDelete: Array[Part] = []
	currentPartGroup = GetAll(!insta)
	if !insta:
		ResetForDelete()
		DeleteAction()
	for part in currentPartGroup:
		toDelete.append(part)
	while toDelete.size() > 0:
		if insta:
			toDelete[0].queue_free()
		else:
			toDelete[0].Delete()
		toDelete.remove_at(0)
	if !insta:
		AudioPlayer.ins.PlaySound(5)
	else:
		currentPartGroup.clear()

func ResetForDelete():
	if mouseGrabbed:
		return
	prevPositions.clear()
	prevRotations.clear()
	prevScales.clear()
	prevIndexes.clear()
	prevFlipHs.clear()
	prevFlipVs.clear()
	for part in currentPartGroup:
		prevPositions.append(part.position)
		prevRotations.append(part.rotation)
		prevScales.append(part.scale.x)
		prevIndexes.append(part.get_index())
		prevFlipHs.append(part.flip_h)
		prevFlipVs.append(part.flip_v)

func SetOverride(value: bool):
	overrideColours = value
	if overrideColours:
		for button in decorButtons:
			button.SetMat(colorMaterial)
	else:
		for button in decorButtons:
			button.SetMat()

func FlipH():
	ResetFlipHs()
	for part in currentPartGroup:
		part.FlipH()
		part.SpawnAnimation()
	FlipHAction()
	AudioPlayer.ins.PlaySound(0)

func FlipV():
	ResetFlipVs()
	for part in currentPartGroup:
		part.FlipV()
		part.SpawnAnimation()
	FlipVAction()
	AudioPlayer.ins.PlaySound(0)

func ResetFlipHs():
	if mouseGrabbed:
		return
	prevFlipHs.clear()
	for part in currentPartGroup:
		prevFlipHs.append(part.flip_h)
	
func ResetFlipVs():
	if mouseGrabbed:
		return
	prevFlipVs.clear()
	for part in currentPartGroup:
		prevFlipVs.append(part.flip_v)

func ChangeSelectedColourChannel(color: Color, channel: int):
	for part in currentPartGroup:
		part.SetColorChannel(color, channel)

func SortCurrentPartGroupLesser():
	currentPartGroup.sort_custom(func (a, b): 
		if a.get_index() < b.get_index():
			var holdPos = prevPositions[currentPartGroup.find(b)]
			prevPositions[currentPartGroup.find(b)] = prevPositions[currentPartGroup.find(a)]
			prevPositions[currentPartGroup.find(a)] = holdPos
			var holdRot = prevRotations[currentPartGroup.find(b)]
			prevRotations[currentPartGroup.find(b)] = prevRotations[currentPartGroup.find(a)]
			prevRotations[currentPartGroup.find(a)] = holdRot
			var holdScale = prevScales[currentPartGroup.find(b)]
			prevScales[currentPartGroup.find(b)] = prevScales[currentPartGroup.find(a)]
			prevScales[currentPartGroup.find(a)] = holdScale
			var holdFlipH = prevFlipHs[currentPartGroup.find(b)]
			prevFlipHs[currentPartGroup.find(b)] = prevFlipHs[currentPartGroup.find(a)]
			prevFlipHs[currentPartGroup.find(a)] = holdFlipH
			var holdFlipV = prevFlipVs[currentPartGroup.find(b)]
			prevFlipVs[currentPartGroup.find(b)] = prevFlipVs[currentPartGroup.find(a)]
			prevFlipVs[currentPartGroup.find(a)] = holdFlipV
			var holdIndex = prevIndexes[currentPartGroup.find(b)]
			prevIndexes[currentPartGroup.find(b)] = prevIndexes[currentPartGroup.find(a)]
			prevIndexes[currentPartGroup.find(a)] = holdIndex
		return a.get_index() < b.get_index())

func SortCurrentPartGroupGreater():
	currentPartGroup.sort_custom(func (a, b): 
		if a.get_index() > b.get_index():
			var holdPos = prevPositions[currentPartGroup.find(b)]
			prevPositions[currentPartGroup.find(b)] = prevPositions[currentPartGroup.find(a)]
			prevPositions[currentPartGroup.find(a)] = holdPos
			var holdRot = prevRotations[currentPartGroup.find(b)]
			prevRotations[currentPartGroup.find(b)] = prevRotations[currentPartGroup.find(a)]
			prevRotations[currentPartGroup.find(a)] = holdRot
			var holdScale = prevScales[currentPartGroup.find(b)]
			prevScales[currentPartGroup.find(b)] = prevScales[currentPartGroup.find(a)]
			prevScales[currentPartGroup.find(a)] = holdScale
			var holdFlipH = prevFlipHs[currentPartGroup.find(b)]
			prevFlipHs[currentPartGroup.find(b)] = prevFlipHs[currentPartGroup.find(a)]
			prevFlipHs[currentPartGroup.find(a)] = holdFlipH
			var holdFlipV = prevFlipVs[currentPartGroup.find(b)]
			prevFlipVs[currentPartGroup.find(b)] = prevFlipVs[currentPartGroup.find(a)]
			prevFlipVs[currentPartGroup.find(a)] = holdFlipV
			var holdIndex = prevIndexes[currentPartGroup.find(b)]
			prevIndexes[currentPartGroup.find(b)] = prevIndexes[currentPartGroup.find(a)]
			prevIndexes[currentPartGroup.find(a)] = holdIndex
		return a.get_index() > b.get_index())

var img: Image

var filePath: String

func MakeSticker():
	ClearControlGroup()
	CameraEffects()
	stickerCap.get_node("cam").position = get_viewport().get_visible_rect().size / 2
	Game.ins.remove_child(fishRef)
	stickerCap.add_child(fishRef)
	await RenderingServer.frame_post_draw
	img = stickerCap.get_texture().get_image()
	CropSticker()
	SaveImg()
	stickerCap.remove_child(fishRef)
	Game.ins.add_child(fishRef)
	

func TakePicture():
	ClearControlGroup()
	Game.ins.hud.visible = false
	Game.ins.toolbar.visible = false
	await RenderingServer.frame_post_draw
	img = get_viewport().get_texture().get_image()
	img = img.get_region(Rect2i((img.get_width() / 10.0) * 3 as int, 0 as int, (img.get_width() / 10.0) * 4 as int, img.get_height() as int))
	SaveImg()
	CameraEffects()
	Game.ins.hud.visible = true
	Game.ins.toolbar.visible = true

func SaveImg():
	if OS.get_name() == "Web":
		TakeWebPicture()
		return
	if nameEdit.text == "":
		fileDialog.current_file = "Picture Of Friend"
	else:
		fileDialog.current_file = "Picture Of " + nameEdit.text
	fileDialog.visible = true

func CameraEffects():
	AudioPlayer.ins.PlaySound(6)
	var flash: ColorRect = Game.ins.cameraFlash
	flash.color = Color(1.0, 1.0, 1.0, 1.0)
	var flashTween: Tween = flash.create_tween()
	flashTween.tween_property(flash, "color", Color(1.0, 1.0, 1.0, 0.0), 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func GetFilePath(path: String):
	filePath = path

func SwitchDirectory(_path: String):
	print("Switching Directory")
	if nameEdit.text == "":
		fileDialog.current_file = "Picture Of Friend"
	else:
		fileDialog.current_file = "Picture Of " + nameEdit.text

func SavePicture():
	if !filePath.ends_with(".png"):
		filePath += ".png"
	img.save_png(filePath)

func TakeWebPicture():
	if nameEdit.text == "":
		JavaScriptBridge.download_buffer(img.save_png_to_buffer(), "Picture Of Friend.png")
	else:
		JavaScriptBridge.download_buffer(img.save_png_to_buffer(), "Picture Of " + nameEdit.text + ".png")

func CropSticker():
	for i in range(4):
		img.rotate_90(CLOCKWISE)
		var data = img.get_data()
		var amountToCrop: int = 0
		while !FindPixels(data, amountToCrop + 500):
			amountToCrop += 500
		while !FindPixels(data, amountToCrop + 125):
			amountToCrop += 125
		while !FindPixels(data, amountToCrop + 25):
			amountToCrop += 25
		while !FindPixels(data, amountToCrop + 5):
			amountToCrop += 5
		img.rotate_180()
		img.crop((img.get_width()) as int, img.get_height() - amountToCrop as int)
		img.rotate_180()

func FindPixels(data, amount: int = 0) -> bool:
	var skipTo: int = img.get_width() * 4 * amount
	for i in img.get_width():
		if data[(4 * i) + 3 + skipTo] > 0:
			return true
	return false

signal Canceled(val: bool)

func DeleteAllConfirmation(val: bool):
	Canceled.emit(val)