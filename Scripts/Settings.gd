extends CanvasLayer

var menuActive: bool = false

@export var selectMaterial: Material
@export var dangerMaterial: Material

func SecretTestSprites(val: bool):
	Game.ins.hud.showTestParts = val
	Game.ins.hud.UpdateTags()

func CanGoBehind(val: bool):
	Game.ins.hud.SetCanGoBehind(val)

func _process(_delta):
	if !menuActive:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		BackButton()
		AudioPlayer.ins.PlaySound(3)

func SetActive(value: bool):
	menuActive = value

func ChangeSelectColour(colour: Color):
	selectMaterial.set_shader_parameter("color_hue", colour)

func ChangeDangerColour(colour: Color):
	dangerMaterial.set_shader_parameter("color_hue", colour)

func BackButton():
	if !menuActive:
		return
	menuActive = false
	Game.ins.HideSettings()