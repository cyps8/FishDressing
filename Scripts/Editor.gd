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

	rPickerRef.color = Color.CYAN
	gPickerRef.color = Color.YELLOW
	bPickerRef.color = Color.MAGENTA
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

func CreateNewDecor(id: int = 0):
	var newDecor = partIns.instantiate() as Part
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
	SetMouseGrabbed(false)

func SetMouseGrabbed(value: bool):
	if mouseGrabbed != value:
		MouseGrabbed.emit(value)
		#Game.ins.toolbar.AddActionLabel("Action: Mouse action")
	mouseGrabbed = value

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
	if !Input.is_action_pressed("Interact"):
		SetMouseGrabbed(false)
	if Input.is_action_just_pressed("RotateLeft") && Input.is_action_pressed("Control") && !mouseGrabbed:
		SelectAll()
	if currentPartGroup.size() > 0:
		if Input.is_action_just_released("Interact"):
			for part in currentPartGroup:
				part.SetFakeMouse()
		if Input.is_action_just_pressed("RotateRight") && Input.is_action_pressed("Control") && !mouseGrabbed:
			Duplicate()
		if Input.is_action_just_pressed("Delete")  && !Input.is_action_pressed("Control"):
			DeleteAllSelected()
			SetMouseGrabbed(false)
			return
		if Input.is_action_just_pressed("Flip") && !Input.is_action_pressed("Control"):
			if Input.is_action_pressed("Shift"):
				FlipV()
			else:
				FlipH()
		if Input.is_action_pressed("ScaleUp") && !Input.is_action_pressed("Control"):
			if Input.is_action_pressed("Shift"):
				ChangeScale(1.05)
			else:
				ChangeScale(1.01)
		elif Input.is_action_pressed("ScaleDown") && !Input.is_action_pressed("Control"):
			if Input.is_action_pressed("Shift"):
				ChangeScale(0.95)
			else:
				ChangeScale(0.99)
		if Input.is_action_pressed("RotateLeft") && !Input.is_action_pressed("Control"):
			if Input.is_action_pressed("Shift"):
				RotatePart(-0.05)
			else:
				RotatePart(-0.01)
		elif Input.is_action_pressed("RotateRight") && !Input.is_action_pressed("Control"):
			if Input.is_action_pressed("Shift"):
				RotatePart(0.05)
			else:
				RotatePart(0.01)
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
			SetMouseGrabbed(false)
			if currentPartGroup.size() > 0:
				var soundsPlayed: Array[int] = []
				for part in currentPartGroup:
					var soundId: int = part.partData.materialSound
					if !soundsPlayed.has(soundId):
						AudioPlayer.ins.PlayMatSound(soundId)
						soundsPlayed.append(soundId)

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
			#part.ResetMoveValues()
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
			part.SpawnAnimation()
			allInGroup = false
	if allInGroup:
		ClearControlGroup()
	else:
		AudioPlayer.ins.PlaySound(0)

func Duplicate(selectedPart: Part = null):
	if selectedPart:
		SelectPart(selectedPart, true, false)
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
		MouseGrabbed.connect(part.MouseGrabbed)
		part.MouseGrabbed(mouseGrabbed)
		part.SpawnAnimation()
	if selectedPart != null:
		SetMouseGrabbed(true)
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
		if index > layerLimit && (i - currentPartGroup.size()) != (index - fishRef.get_child_count() - 1):
			fishRef.move_child(currentPartGroup[i], index - 1)

func MoveToTop():
	currentPartGroup.sort_custom(func (a, b): return a.get_index() < b.get_index())
	for part in currentPartGroup:
		fishRef.move_child(part, fishRef.get_child_count() - 1)

func MoveToBottom():
	currentPartGroup.sort_custom(func (a, b): return a.get_index() > b.get_index())
	for part in currentPartGroup:
		fishRef.move_child(part, layerLimit)

func SetCanGoBehind(val: bool):
	if val:
		layerLimit = 0
	else:
		layerLimit = 1
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
	else:
		currentPartGroup.clear()

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
		part.SpawnAnimation()
	AudioPlayer.ins.PlaySound(0)

func FlipV():
	for part in currentPartGroup:
		part.FlipV()
		part.SpawnAnimation()
	AudioPlayer.ins.PlaySound(0)

func ChangeSelectedColourChannel(color: Color, channel: int):
	for part in currentPartGroup:
		part.SetColorChannel(color, channel)

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