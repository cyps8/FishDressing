extends CanvasLayer

class_name Editor

static var ins: Editor

@export var partIns: PackedScene

@export var decorButtonIns: PackedScene

@export var partDataList: Array[PartData]

var decorButtons: Array[DecorButton] = []

var currentPartGroup: Array[Part] = []

var currentlyManipulating: bool = false

var fishRef: CanvasGroup

@export var colorMaterial: Material

var pickedColorR: Color = Color.WHITE
var pickedColorG: Color = Color.WHITE
var pickedColorB: Color = Color.WHITE

var rPickerRef: ColorPickerButton
var gPickerRef: ColorPickerButton
var bPickerRef: ColorPickerButton

var overrideColours: bool = false
var overrideButton: CheckButton

var showTestParts: bool = false

var currentCategory: int = 0

var categories: TabBar

var nameEdit: LineEdit
var nameType: Label

var texting: bool = false

var clickedOut: TextureButton

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

	rPickerRef.color = Color.WHITE
	gPickerRef.color = Color.WHITE
	bPickerRef.color = Color.WHITE
	pickedColorR = rPickerRef.color
	pickedColorG = gPickerRef.color
	pickedColorB = bPickerRef.color
	colorMaterial.set_shader_parameter("red_color", pickedColorR)
	colorMaterial.set_shader_parameter("green_color", pickedColorG)
	colorMaterial.set_shader_parameter("blue_color", pickedColorB)

func _ready():
	overrideButton = %OverrideDefault
	rPickerRef = %ColorR
	gPickerRef = %ColorG
	bPickerRef = %ColorB
	categories = %Categories

	nameEdit = %EnterName
	nameType = %FishType

	clickedOut = %ClickedOut

	ResetEditor()

	for i in partDataList.size():
		var newButton: DecorButton = decorButtonIns.instantiate()
		newButton.Setup(partDataList[i])
		newButton.connect("button_down", Callable(self, "CreateNewDecor").bind(i))
		decorButtons.append(newButton)
		%Decors.add_child(newButton)

		fishRef = get_parent().get_node("Fish")

func InText(value: bool):
	texting = value

func CreateNewDecor(id: int = 0):
	var newDecor = partIns.instantiate() as Part
	newDecor.partData = partDataList[id]
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
	currentlyManipulating = true
	newDecor.SpawnAnimation()
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
		var tagToCompare: PartData.Tag
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
	currentlyManipulating = false

func _process(_delta):
	if Game.ins.cogMenu.is_inside_tree():
		return
	if Input.is_action_just_pressed("ui_cancel"):
		Game.ins.ShowCogMenu()
		return
	if texting:
		return
	if Input.is_action_just_pressed("RotateLeft") && Input.is_action_pressed("Control") && !Input.is_action_pressed("Interact"):
		SelectAll()
	if currentPartGroup.size() > 0:
		if Input.is_action_just_released("Interact"):
			for part in currentPartGroup:
				part.SetFakeMouse()
		if Input.is_action_just_pressed("RotateRight") && Input.is_action_pressed("Control") && !Input.is_action_pressed("Interact"):
			Duplicate()
		if Input.is_action_just_pressed("Delete")  && !Input.is_action_pressed("Control"):
			DeleteAllSelected()
			currentlyManipulating = false
			return
		if Input.is_action_just_pressed("Flip") && !Input.is_action_pressed("Control"):
			if Input.is_action_pressed("Shift"):
				FlipV()
			else:
				FlipH()
		if Input.is_action_pressed("ScaleUp") && !Input.is_action_pressed("Control"):
			if Input.is_action_pressed("Shift"):
				ChangeScale(1.05, !currentlyManipulating)
			else:
				ChangeScale(1.01, !currentlyManipulating)
		elif Input.is_action_pressed("ScaleDown") && !Input.is_action_pressed("Control"):
			if Input.is_action_pressed("Shift"):
				ChangeScale(0.95, !currentlyManipulating)
			else:
				ChangeScale(0.99, !currentlyManipulating)
		if Input.is_action_pressed("RotateLeft") && !Input.is_action_pressed("Control"):
			if Input.is_action_pressed("Shift"):
				RotatePart(-0.05, !currentlyManipulating)
			else:
				RotatePart(-0.01, !currentlyManipulating)
		elif Input.is_action_pressed("RotateRight") && !Input.is_action_pressed("Control"):
			if Input.is_action_pressed("Shift"):
				RotatePart(0.05, !currentlyManipulating)
			else:
				RotatePart(0.01, !currentlyManipulating)
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
		if Input.is_action_pressed("Interact") && currentlyManipulating:
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
		elif Input.is_action_just_released("Interact") && !Input.is_action_pressed("Control"):
			var partsToDelete: Array[Part] = []
			for part in currentPartGroup:
				if !part.IsInSafeZone(fishRef.get_node("FishBody") as Sprite2D):
					partsToDelete.append(part)
			if partsToDelete.size() > 0:
				AudioPlayer.ins.PlaySound(5)
			while partsToDelete.size() > 0:
				partsToDelete[0].Delete()
				partsToDelete.remove_at(0)
			currentlyManipulating = false
			if currentPartGroup.size() > 0:
				AudioPlayer.ins.PlaySound(4)

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

func ResetSelectedMoveValues(fake: bool = false):
	for part in currentPartGroup:
		part.ResetMoveValues(fake)

func RotatePart(amount: float, fake: bool = false):
	for part in currentPartGroup:
		part.RotateBy(amount, fake)

func SetRotation(value: float, move: bool = false, fake: bool = false):
	for part in currentPartGroup:
		part.SetRotation(value, move, fake)

func SetScale(value: float, move: bool = false, fake: bool = false):
	for part in currentPartGroup:
		part.SetScale(value, move, fake)

func ChangeScale(value: float, fake: bool = false):
	for part in currentPartGroup:
		part.ScaleBy(value, fake)

func SelectPart(selectedPart: Part):
	if !currentPartGroup.has(selectedPart):
		ClearControlGroup()
		selectedPart.SetControlGroup(true)
	currentlyManipulating = true
	for part in currentPartGroup:
		part.ResetMoveValues()
		part.SpawnAnimation()
	AudioPlayer.ins.PlaySound(0)

func GetAll() -> Array[Part]:
	var allParts: Array[Part] = []
	for part in fishRef.get_children():
		if part.is_in_group("Part") && !part.deleted:
			allParts.append(part)
	return allParts

func SelectAll():
	var allInGroup = true
	for part in GetAll():
		if !part.controlGrouped:
			part.SetControlGroup(true)
			if !Input.is_action_pressed("Interact"):
				part.SetFakeMouse()
			part.ResetMoveValues(!Input.is_action_pressed("Interact"))
			part.SpawnAnimation(!Input.is_action_pressed("Interact"), !Input.is_action_pressed("Interact"))
			allInGroup = false
	if allInGroup:
		ClearControlGroup()
	else:
		AudioPlayer.ins.PlaySound(0)

func Duplicate(selectedPart: Part = null):
	if selectedPart && !currentPartGroup.has(selectedPart):
		selectedPart.SetControlGroup(true)
	var dupedParts: Array[Part] = []
	currentPartGroup.sort_custom(func (a, b): return a.get_index() < b.get_index())
	for part in currentPartGroup:
		var dupedPart: Part = part.duplicate()
		dupedPart.partData = part.partData
		dupedPart.UpdateDuplicateRefs(part)
		fishRef.add_child(dupedPart)
		dupedParts.append(dupedPart)
	ClearControlGroup()
	for part in dupedParts:
		part.SetControlGroup(true)
		if !Input.is_action_pressed("Interact"):
			part.SetFakeMouse()
		part.ResetMoveValues(!Input.is_action_pressed("Interact"))
		part.SpawnAnimation(!Input.is_action_pressed("Interact"), !Input.is_action_pressed("Interact"))
	currentlyManipulating = true
	AudioPlayer.ins.PlaySound(0)

func MoveUp():
	currentPartGroup.sort_custom(func (a, b): return a.get_index() > b.get_index())
	for part in currentPartGroup:
		var index = part.get_index()
		if index < fishRef.get_child_count():
			fishRef.move_child(part, index + 1)

func MoveDown():
	currentPartGroup.sort_custom(func (a, b): return a.get_index() < b.get_index())
	for i in currentPartGroup.size():
		var index = currentPartGroup[i].get_index()
		if index > 1 && (i - currentPartGroup.size()) != (index - fishRef.get_child_count() - 1):
			fishRef.move_child(currentPartGroup[i], index - 1)

func MoveToTop():
	currentPartGroup.sort_custom(func (a, b): return a.get_index() < b.get_index())
	for part in currentPartGroup:
		fishRef.move_child(part, fishRef.get_child_count() - 1)

func MoveToBottom():
	currentPartGroup.sort_custom(func (a, b): return a.get_index() > b.get_index())
	for part in currentPartGroup:
		fishRef.move_child(part, 1)

func SetFakeMouse():
	for part in currentPartGroup:
		part.SetFakeMouse()

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
	while currentPartGroup.size() > 0:
		currentPartGroup[0].Delete()
	AudioPlayer.ins.PlaySound(5)

func DeleteAll(insta: bool = true):
	var toDelete: Array[Part] = []
	for part in GetAll():
		toDelete.append(part)
	while toDelete.size() > 0:
		if insta:
			toDelete[0].queue_free()
		else:
			toDelete[0].Delete()
		toDelete.remove_at(0)
	if !insta:
		AudioPlayer.ins.PlaySound(5)

func SetOverride(value: bool):
	overrideColours = value
	if overrideColours:
		for button in decorButtons:
			button.SetMat(colorMaterial)
	else:
		for button in decorButtons:
			button.SetMat()

func FlipH():
	for part in currentPartGroup:
		part.FlipH()
		part.SpawnAnimation(currentlyManipulating)
	AudioPlayer.ins.PlaySound(0)

func FlipV():
	for part in currentPartGroup:
		part.FlipV()
		part.SpawnAnimation(currentlyManipulating)
	AudioPlayer.ins.PlaySound(0)

func ChangeSelectedColourChannel(color: Color, channel: int):
	for part in currentPartGroup:
		part.SetColorChannel(color, channel)

func TakePicture():
	pass