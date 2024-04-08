extends CanvasLayer

var selectDisabled: bool = true

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

func _ready():
	selectedTools = $c/SelectedTools
	globalTools = $c/GlobalTools

	scaleSlider = selectedTools.get_node("ScaleSlider")
	rotationSlider = selectedTools.get_node("RotationSlider")

	colorPickerR = selectedTools.get_node("ColorR")
	colorPickerG = selectedTools.get_node("ColorG")
	colorPickerB = selectedTools.get_node("ColorB")

	SelectDisable(true)

func _process(_delta):
	if Game.ins.hud.currentPartGroup.size() > 0 && selectDisabled:
		SelectDisable(false)
	if Game.ins.hud.currentPartGroup.size() == 0 && !selectDisabled:
		SelectDisable(true)
	if !selectDisabled:
		UpdateValues()
	if Game.ins.hud.GetAll().size() == 0:
		globalTools.get_node("DeleteAll").disabled = true
		globalTools.get_node("SelectAll").disabled = true
	else:
		globalTools.get_node("DeleteAll").disabled = false
		globalTools.get_node("SelectAll").disabled = false

	if scalingDown:
		Game.ins.hud.ChangeScale(0.98, true)
	if scalingUp:
		Game.ins.hud.ChangeScale(1.02, true)
	if rotatingLeft:
		Game.ins.hud.RotatePart(-0.05, true)
	if rotatingRight:
		Game.ins.hud.RotatePart(0.05, true)

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
	if val:
		Game.ins.hud.SetFakeMouse()
		Game.ins.hud.ResetSelectedMoveValues(true)
	scalingDown = val

func ScaleUp(val: bool):
	if val:
		Game.ins.hud.SetFakeMouse()
		Game.ins.hud.ResetSelectedMoveValues(true)
	scalingUp = val

func ScaleChanged(_val: float):
	pass

func ScaleChangeEnded(_val: float):
	pass

func RotateLeft(val: bool):
	if val:
		Game.ins.hud.SetFakeMouse()
		Game.ins.hud.ResetSelectedMoveValues(true)
	rotatingLeft = val

func RotateRight(val: bool):
	if val:
		Game.ins.hud.SetFakeMouse()
		Game.ins.hud.ResetSelectedMoveValues(true)
	rotatingRight = val

func RotationChanged(_val: float):
	pass

func RotationChangeEnded(_val: float):
	pass

func ColorPickChanged(_newColor: Color, _val: int = 0):
	pass