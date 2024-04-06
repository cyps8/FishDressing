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

var overrideColours: bool = false

func _init():
	ins = self

func _ready():
	pickedColorR = %ColorR.color
	pickedColorG = %ColorG.color
	pickedColorB = %ColorB.color
	colorMaterial.set_shader_parameter("red_color", pickedColorR)
	colorMaterial.set_shader_parameter("green_color", pickedColorG)
	colorMaterial.set_shader_parameter("blue_color", pickedColorB)
	for i in partDataList.size():
		var newButton: DecorButton = decorButtonIns.instantiate()
		newButton.Setup(partDataList[i])
		newButton.connect("button_down", Callable(self, "CreateNewDecor").bind(i))
		decorButtons.append(newButton)
		%Decors.add_child(newButton)

		fishRef = get_parent().get_node("Fish")

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
	for part in currentPartGroup:
		part.SetControlGroup(false)
	currentPartGroup.clear()
	currentPartGroup.append(newDecor)
	currentlyManipulating = true
	newDecor.SpawnAnimation()

func _process(_delta):
	if Input.is_action_just_pressed("RotateLeft") && Input.is_action_pressed("Control") && !Input.is_action_pressed("Interact"):
		var allInGroup = true
		for part in fishRef.get_children():
			if part.is_in_group("Part") && !part.controlGrouped:
				part.SetControlGroup(true)
				if !currentPartGroup.has(part):
					currentPartGroup.append(part)
				allInGroup = false
		if allInGroup:
			for part in fishRef.get_children():
				if part.is_in_group("Part"):
					part.SetControlGroup(false)
			currentPartGroup.clear()
			
	if currentPartGroup.size() > 0:
		if Input.is_action_just_pressed("Delete"):
			for part in currentPartGroup:
				part.SetControlGroup(false)
				part.Delete()
			currentPartGroup.clear()
			currentlyManipulating = false
			return
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
			if Input.is_action_pressed("ScaleUp"):
				if Input.is_action_pressed("Shift"):
					ChangeScale(1.05)
				else:
					ChangeScale(1.01)
			elif Input.is_action_pressed("ScaleDown"):
				if Input.is_action_pressed("Shift"):
					ChangeScale(0.95)
				else:
					ChangeScale(0.99)
			if Input.is_action_pressed("RotateLeft"):
				if Input.is_action_pressed("Shift"):
					RotatePart(-0.05)
				else:
					RotatePart(-0.01)
			elif Input.is_action_pressed("RotateRight"):
				if Input.is_action_pressed("Shift"):
					RotatePart(0.05)
				else:
					RotatePart(0.01)
			if Input.is_action_just_pressed("MoveUp"):
				if Input.is_action_pressed("Shift"):
					MoveToTop()
				else:
					MoveUp()
			elif Input.is_action_just_pressed("MoveDown"):
				if Input.is_action_pressed("Shift"):
					MoveToBottom()
				else:
					MoveDown()
			for part in currentPartGroup:
				part.UpdateMovePosition()
		elif Input.is_action_just_released("Interact"):
			var partsToDelete: Array[Part] = []
			for part in currentPartGroup:
				if !part.IsInSafeZone(fishRef.get_node("FishBody") as Sprite2D):
					part.SetControlGroup(false)
					partsToDelete.append(part)
			for part in partsToDelete:
				part.Delete()
				currentPartGroup.erase(part)
			for part in currentPartGroup:
				if !part.controlGrouped:
					currentPartGroup.erase(part)
			currentlyManipulating = false
		elif Input.is_action_just_pressed("Interact") && !currentlyManipulating:
			for part in currentPartGroup:
				part.SetControlGroup(false)

func UpdateSafeColour(part: Part):
	if part.IsInSafeZone(fishRef.get_node("FishBody") as Sprite2D):
		part.SetDanger(false)
	else:
		part.SetDanger(true)

func RotatePart(amount: float):
	for part in currentPartGroup:
		part.rotation += amount
		part.currentRotation += amount

func SetScale(value: float):
	for part in currentPartGroup:
		part.SetScale(value)

func ChangeScale(value: float):
	for part in currentPartGroup:
		part.ScaleBy(value)

func SelectPart(selectedPart: Part):
	if !currentPartGroup.has(selectedPart):
		currentPartGroup.append(selectedPart)
	for part in currentPartGroup:
		if !part.controlGrouped && part != selectedPart:
			currentPartGroup.erase(part)
	currentlyManipulating = true
	for part in currentPartGroup:
		part.selectOffset = get_viewport().get_mouse_position() - part.position
		part.currentScale = 1.0
		part.currentRotation = 0.0
	
func Duplicate(selectedPart: Part):
	if !currentPartGroup.has(selectedPart):
		currentPartGroup.append(selectedPart)
	var dupedParts: Array[Part] = []
	currentPartGroup.sort_custom(func (a, b): return a.get_index() < b.get_index())
	for part in currentPartGroup:
		var dupedPart: Part = part.duplicate()
		dupedPart.UpdateDuplicateRefs()
		fishRef.add_child(dupedPart)
		dupedPart.SetControlGroup(part.controlGrouped)
		part.SetControlGroup(false)
		dupedParts.append(dupedPart)
	currentPartGroup = dupedParts
	currentlyManipulating = true
	for part in currentPartGroup:
		part.selectOffset = get_viewport().get_mouse_position() - part.position
		part.currentScale = 1.0
		part.currentRotation = 0.0
		part.SpawnAnimation()

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
	currentPartGroup.sort_custom(func (a, b): return a.get_index() > b.get_index())
	for part in currentPartGroup:
		fishRef.move_child(part, 1)

func MoveToBottom():
	currentPartGroup.sort_custom(func (a, b): return a.get_index() < b.get_index())
	for part in currentPartGroup:
		fishRef.move_child(part, fishRef.get_child_count() - 1)

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

func SetOverride(value: bool):
	overrideColours = value
	if overrideColours:
		for button in decorButtons:
			button.SetMat(colorMaterial)
	else:
		for button in decorButtons:
			button.SetMat()