extends CanvasLayer

var selectDisabled: bool = false

var selectedTools: Panel

var globalTools: Control

var scaleSlider: HSlider
var rotationSlider: HSlider

var colorPickerR: ColorPickerButton
var colorPickerG: ColorPickerButton
var colorPickerB: ColorPickerButton

var scalingDown: bool = false
var scalingUp: bool = false
var rotatingLeft: bool = false
var rotatingRight: bool = false

var refPart: Part

var sliderScaling: bool = false
var sliderRotating: bool = false

@export var actionLabelIns: PackedScene

var actions: VBoxContainer

func _ready():
	selectedTools = $c/SelectedTools
	globalTools = $c/GlobalTools
	actions = $c/Actions

	scaleSlider = selectedTools.get_node("ScaleSlider")
	rotationSlider = selectedTools.get_node("RotationSlider")

	colorPickerR = selectedTools.get_node("ColorR")
	colorPickerG = selectedTools.get_node("ColorG")
	colorPickerB = selectedTools.get_node("ColorB")

	SelectDisable(true)

func AddActionLabel(text: String):
	var newLabel: Label = actionLabelIns.instantiate()
	newLabel.text = text
	actions.add_child(newLabel)

func _process(_delta):
	SelectDisable(!Game.ins.hud.currentPartGroup.size() > 0)
	if !selectDisabled:
		UpdateValues()
	if Game.ins.hud.GetAll().size() == 0:
		globalTools.get_node("DeleteAll").disabled = true
		globalTools.get_node("SelectAll").disabled = true
	else:
		globalTools.get_node("DeleteAll").disabled = false
		globalTools.get_node("SelectAll").disabled = false

	if scalingDown:
		Game.ins.hud.ChangeScale(0.98)
	if scalingUp:
		Game.ins.hud.ChangeScale(1.02)
	if rotatingLeft:
		Game.ins.hud.RotatePart(-0.05)
	if rotatingRight:
		Game.ins.hud.RotatePart(0.05)

func UpdateValues():
	refPart = Game.ins.hud.currentPartGroup[Game.ins.hud.currentPartGroup.size() - 1]

	scaleSlider.value = refPart.scale.x
	rotationSlider.value = rad_to_deg(refPart.rotation)
	if refPart.partData.redChannel:
		colorPickerR.color = refPart.currentRedColor
		colorPickerR.visible = true
	else:
		colorPickerR.visible = false
	if refPart.partData.greenChannel:
		colorPickerG.color = refPart.currentGreenColor
		colorPickerG.visible = true
	else:
		colorPickerG.visible = false
	if refPart.partData.blueChannel:
		colorPickerB.color = refPart.currentBlueColor
		colorPickerB.visible = true
	else:
		colorPickerB.visible = false

func SelectDisable(value: bool):
	if selectDisabled == value:
		return
	selectDisabled = value
	for button in selectedTools.get_children():
		if button is Button || button is CheckButton:
			button.disabled = value
		if button is HSlider:
			button.editable = !value
		if button is ColorPickerButton:
			button.visible = !value

func DeleteAll():
	Game.ins.hud.DeleteAll(false)

func SelectAll():
	Game.ins.hud.SelectAll()

func Undo():
	pass

func Redo():
	pass

func DeleteSelected():
	Game.ins.hud.DeleteAllSelected()

func DuplicateSelected():
	Game.ins.hud.Duplicate()

func FlipH():
	Game.ins.hud.FlipH()

func FlipV():
	Game.ins.hud.FlipV()

func MoveToBottom():
	Game.ins.hud.MoveToBottom()

func MoveBack():
	Game.ins.hud.MoveDown()

func MoveForward():
	Game.ins.hud.MoveUp()

func MoveToTop():
	Game.ins.hud.MoveToTop()

func ScaleDown(val: bool):
	scalingDown = val

func ScaleUp(val: bool):
	scalingUp = val

func ScaleChangeStarted():
	sliderScaling = true
	
func ScaleChanged(_val: float):
	if sliderScaling:
		Game.ins.hud.SetScale(_val)

func ScaleChangeEnded(_val: float):
	sliderScaling = false

func RotateLeft(val: bool):
	rotatingLeft = val

func RotateRight(val: bool):
	rotatingRight = val

func RotationChangeStarted():
	sliderRotating = true

func RotationChanged(_val: float):
	if sliderRotating:
		Game.ins.hud.SetRotation(deg_to_rad(_val))

func RotationChangeEnded(_val: float):
	sliderRotating = false

var picking: bool = false

func ColorPickChanged(_newColor: Color, _val: int = 0):
	if picking:
		Game.ins.hud.ChangeSelectedColourChannel(_newColor, _val)

func PickerState(value: bool):
	picking = value
	Game.ins.hud.clickedOut.visible = !value