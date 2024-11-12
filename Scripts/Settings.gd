extends CanvasLayer

var menuActive: bool = false

@export var selectMaterial: Material
@export var dangerMaterial: Material

var fullScreen: bool = true

func SecretTestSprites(val: bool):
	Editor.ins.showTestParts = val
	Editor.ins.UpdateTags()

func CanGoBehind(val: bool):
	Editor.ins.SetCanGoBehind(val)

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

func ToggleFullscreen(toggle: bool):
	fullScreen = toggle
	if toggle:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

var masterSliderRef: HSlider
var musicSliderRef: HSlider
var sfxSliderRef: HSlider

var canGoBehindRef: CheckButton
var showTestPartsRef: CheckButton
var cursorTeethRef: CheckButton
var calmerMusicRef: CheckButton

var selectColourRef: ColorPickerButton
var dangerColourRef: ColorPickerButton

var fullscreenRef: CheckButton

func _ready():
	masterSliderRef = %MasterVolume
	musicSliderRef = %MusicVolume
	sfxSliderRef = %SFXVolume

	canGoBehindRef = %CanGoBehind
	showTestPartsRef = %SecretSprites
	cursorTeethRef = %CursorTeeth
	calmerMusicRef = %CalmerMusic

	selectColourRef = %SelectColour
	dangerColourRef = %DangerColour

	fullscreenRef = %FullScreenButton
	LoadSettings()

func SaveSettings():
	if OS.get_name() == "Web":
		return
	var saveFile = FileAccess.open("user://settings.save", FileAccess.WRITE)
	saveFile.store_float(masterSliderRef.value)
	saveFile.store_float(musicSliderRef.value)
	saveFile.store_float(sfxSliderRef.value)
	saveFile.store_8(Game.ins.calmerMusic as int)
	saveFile.store_8(Game.ins.cursorTeeth as int)
	saveFile.store_8(Editor.ins.canGoBehind as int)
	saveFile.store_8(Editor.ins.showTestParts as int)
	var selCol = selectMaterial.get_shader_parameter("color_hue")
	saveFile.store_float(selCol.r)
	saveFile.store_float(selCol.g)
	saveFile.store_float(selCol.b)
	var danCol = dangerMaterial.get_shader_parameter("color_hue")
	saveFile.store_float(danCol.r)
	saveFile.store_float(danCol.g)
	saveFile.store_float(danCol.b)
	saveFile.store_8(fullScreen as int)

func LoadSettings():
	if OS.get_name() == "Web":
		return
	if not FileAccess.file_exists("user://settings.save"):
		SaveSettings()
		return

	var saveFile = FileAccess.open("user://settings.save", FileAccess.READ)
	masterSliderRef.value = saveFile.get_float()
	musicSliderRef.value = saveFile.get_float()
	sfxSliderRef.value = saveFile.get_float()
	Game.ins.CalmerMusic(saveFile.get_8())
	calmerMusicRef.button_pressed = Game.ins.calmerMusic
	Game.ins.CursorTeeth(saveFile.get_8())
	cursorTeethRef.button_pressed = Game.ins.cursorTeeth
	CanGoBehind(saveFile.get_8())
	canGoBehindRef.button_pressed = Editor.ins.canGoBehind
	SecretTestSprites(saveFile.get_8())
	showTestPartsRef.button_pressed = Editor.ins.showTestParts
	ChangeSelectColour(Color(saveFile.get_float(), saveFile.get_float(), saveFile.get_float()))
	selectColourRef.color = selectMaterial.get_shader_parameter("color_hue")
	ChangeDangerColour(Color(saveFile.get_float(), saveFile.get_float(), saveFile.get_float()))
	dangerColourRef.color = dangerMaterial.get_shader_parameter("color_hue")
	ToggleFullscreen(saveFile.get_8())
	fullscreenRef.button_pressed = fullScreen