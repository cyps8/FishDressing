extends Node2D

class_name Game

static var ins: Game

var mainMenu: CanvasLayer
var hud: CanvasLayer
var fish: CanvasGroup
var fishPicker: CanvasLayer
var settingsButton: CanvasLayer
var settings: CanvasLayer
var cogMenu: CanvasLayer
var toolbar: CanvasLayer
var credits: CanvasLayer
var saveSystem: CanvasLayer
var musicPlayer: AudioStreamPlayer
var kisses: Node2D
var snowEffect: CanvasLayer
var mainMenuSnowEffect: CPUParticles2D

var selectedFish: FishData

var cameraFlash: ColorRect

var particles: CPUParticles2D

var calmerMusic: bool = false
var cursorTeeth: bool = false

var editorOpen: bool = false

@export var demo: bool

@export var cursors: Array[Texture2D]

@export var music: Array[AudioStream]

@export var drpIns: PackedScene

@export var fishDataList: Array[FishData]

var drpRef: Node

func _init():
	ins = self

func CalmerMusic(_val: bool):
	pass
	# calmerMusic = val
	# if musicPlayer == null:
	# 	musicPlayer = $MusicPlayer
	# var pos: float = musicPlayer.get_playback_position()
	# if val:
	# 	musicPlayer.stream = music[1]
	# else:
	# 	musicPlayer.stream = music[0]
	# musicPlayer.play(pos)

func CursorTeeth(val: bool):
	cursorTeeth = val
	if cursorTeeth:
		Input.set_custom_mouse_cursor(cursors[3], Input.CURSOR_DRAG, Vector2(5, 5))
		SteamManager.ins.UnlockAchievement("CursorTeeth")
	else:
		Input.set_custom_mouse_cursor(cursors[0], Input.CURSOR_DRAG, Vector2(5, 5))

func is_discord_rpc_supported() -> bool:
	return OS.get_name() != "Web" and GDExtensionManager.is_extension_loaded("res://addons/discord-rpc-gd/bin/discord-rpc-gd.gdextension")

func TryInitDRP():
	if !is_discord_rpc_supported():
		return
	var drp = drpIns.instantiate()
	add_child(drp)
	drpRef = drp
	drpRef.SetUp()
	
func SetDRPMainMenu():
	if drpRef == null:
		return
	drpRef.Update("In the Ocean")

func SetDRPFish():
	if drpRef == null:
		return
	drpRef.Update("Dressing a " + selectedFish.name, selectedFish.systemName)

func _ready():
	TryInitDRP()
	SteamManager.ins.SetRPMenu()
	%Demo.visible = demo

	Input.set_custom_mouse_cursor(cursors[0], Input.CURSOR_ARROW,Vector2(5, 5))
	Input.set_custom_mouse_cursor(cursors[1], Input.CURSOR_POINTING_HAND, Vector2(5, 5))
	Input.set_custom_mouse_cursor(cursors[2], Input.CURSOR_IBEAM, Vector2(15, 55))
	Input.set_custom_mouse_cursor(cursors[0], Input.CURSOR_DRAG, Vector2(5, 5))

	mainMenu = $MainMenu
	mainMenu.visible = true

	fish = $Fish
	fish.visible = true
	remove_child(fish)

	fishPicker = $FishPicker
	fishPicker.visible = true
	remove_child(fishPicker)

	hud = $HUD
	hud.visible = true
	remove_child(hud)

	toolbar = $Toolbar
	toolbar.visible = true
	remove_child(toolbar)

	settingsButton = $SettingsButton
	settingsButton.visible = true

	settings = $Settings
	settings.visible = true
	remove_child(settings)

	cogMenu = $CogMenu
	cogMenu.visible = true
	remove_child(cogMenu)

	credits = $Credits
	credits.visible = true
	remove_child(credits)

	saveSystem = $SaveSystem
	saveSystem.visible = true
	remove_child(saveSystem)

	snowEffect = $SnowEffect
	snowEffect.visible = true
	remove_child(snowEffect)
	mainMenuSnowEffect = $MainMenu/C/Group/SnowParticles
	mainMenuSnowEffect.visible = false
	UpdateEvent()

	cameraFlash = $Camera/Flash
	$Camera.visible = true

	particles = $BubbleEffect/Particles

	musicPlayer = $MusicPlayer

	kisses = $Kisses

	if OS.get_name() != "Web" && FileAccess.file_exists("user://backup.backup"):
		$LoadBackup.visible = true

func BackupConf():
	SaveMan.ins.LoadBackUp()

func BackupCancel():
	SaveMan.ins.DeleteBackUp()

func ReturnToMenu():
	if fish.is_inside_tree():
		HideFish()
	if fishPicker.is_inside_tree():
		HideFishPicker()
	if hud.is_inside_tree():
		hud.ResetEditor()
		HideHUD()
	if cogMenu.is_inside_tree():
		HideCogMenu()
	var delay: Tween = create_tween()
	delay.tween_interval(0.5)
	delay.tween_callback(ShowMenu)
	SetDRPMainMenu()
	SteamManager.ins.SetRPMenu()

func LoadSave():
	if mainMenu.is_inside_tree():
		HideMenu()
	if fish.is_inside_tree():
		HideFish()
	if fishPicker.is_inside_tree():
		HideFishPicker()
	if hud.is_inside_tree():
		hud.ResetEditor()
		HideHUD()
	if cogMenu.is_inside_tree():
		HideCogMenu()
	var delay: Tween = create_tween()
	delay.tween_interval(1.1)
	delay.tween_callback(ActuallyLoad)

func ActuallyLoad():
	ShowFish()
	SaveMan.ins.SwapFish()
	ShowHUD()
	SaveMan.ins.LoadFish()
	SetDRPFish()
	SteamManager.ins.SetRPDressing()

func HideMenu():
	mainMenu.SetActive(false)
	var hideMenuTween: Tween = create_tween()
	hideMenuTween.tween_property(mainMenu, "offset:x", -2500, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	hideMenuTween.tween_callback(remove_child.bind(mainMenu))

func ShowMenu():
	Bubbles()
	add_child(mainMenu)
	var showMenuTween: Tween = create_tween()
	showMenuTween.tween_property(mainMenu, "offset:x", 0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	showMenuTween.tween_callback(mainMenu.SetActive.bind(true))

func ShowHUD():
	Bubbles()
	editorOpen = true
	add_child(hud)
	hud.EditorOpened()
	hud.offset = Vector2(0, 900)
	var showHUDTween: Tween = create_tween()
	showHUDTween.tween_property(hud, "offset:y", 0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	add_child(toolbar)
	toolbar.offset = Vector2(-900, 0)
	var showToolbarTween: Tween = create_tween()
	showToolbarTween.tween_property(toolbar, "offset:x", 0, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func HideHUD():
	SaveMan.ins.DeleteBackUp()
	editorOpen = false
	var hideHUDTween: Tween = create_tween()
	hideHUDTween.tween_property(hud, "offset:y", 900, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	hideHUDTween.tween_callback(remove_child.bind(hud))

	var hideToolbarTween: Tween = create_tween()
	hideToolbarTween.tween_property(toolbar, "offset:x", -900, 0.75).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	hideToolbarTween.tween_callback(remove_child.bind(toolbar))

func ShowFish():
	add_child(fish)
	fish.position = Vector2(0, 900)
	var showFishTween: Tween = create_tween()
	showFishTween.tween_property(fish, "position:y", 0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func HideFish():
	var hideFishTween: Tween = create_tween()
	hideFishTween.tween_property(fish, "position:y", 900, 0.8).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	if hud.is_inside_tree():
		hideFishTween.tween_callback(hud.DeleteAll)
	hideFishTween.tween_callback(remove_child.bind(fish))

func ShowFishPicker():
	Bubbles()
	add_child(fishPicker)
	fishPicker.picked = false
	fishPicker.SetFish(-1)
	fishPicker.offset = Vector2(0, 900)
	var showFishPickerTween: Tween = create_tween()
	showFishPickerTween.tween_property(fishPicker, "offset:y", 0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	var fishSoundTween: Tween = create_tween()
	fishSoundTween.tween_interval(0.3)
	fishSoundTween.tween_callback(AudioPlayer.ins.PlayFishSound.bind(fishPicker.currentFish))

func HideFishPicker():
	var hideFishPickerTween: Tween = create_tween()
	hideFishPickerTween.tween_property(fishPicker, "offset:y", 900, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	hideFishPickerTween.tween_callback(remove_child.bind(fishPicker))

func ShowSettings():
	add_child(settings)
	settings.offset = Vector2(0, -900)
	var showSettingsTween: Tween = create_tween()
	showSettingsTween.tween_property(settings, "offset:y", 0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	showSettingsTween.tween_callback(settings.SetActive.bind(true))

func HideSettings():
	settings.SetActive(false)
	var hideSettingsTween: Tween = create_tween()
	hideSettingsTween.tween_property(settings, "offset:y", -900, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	hideSettingsTween.tween_callback(remove_child.bind(settings))
	settings.SaveSettings()

func ShowCogMenu():
	add_child(cogMenu)
	cogMenu.offset = Vector2(0, -900)
	var showCogMenuTween: Tween = create_tween()
	showCogMenuTween.tween_property(cogMenu, "offset:y", 0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	showCogMenuTween.tween_callback(cogMenu.SetActive.bind(true))

func HideCogMenu():
	cogMenu.SetActive(false)
	var hideCogMenuTween: Tween = create_tween()
	hideCogMenuTween.tween_property(cogMenu, "offset:y", -900, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	hideCogMenuTween.tween_callback(remove_child.bind(cogMenu))

func ShowCredits():
	add_child(credits)
	credits.offset = Vector2(0, -900)
	var showCreditsTween: Tween = create_tween()
	showCreditsTween.tween_property(credits, "offset:y", 0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	showCreditsTween.tween_callback(credits.SetActive.bind(true))

func HideCredits():
	var hideCreditsTween: Tween = create_tween()
	hideCreditsTween.tween_property(credits, "offset:y", -900, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	hideCreditsTween.tween_callback(remove_child.bind(credits))

func ShowSaveSystem():
	add_child(saveSystem)
	saveSystem.Update()
	saveSystem.offset = Vector2(0, -900)
	var showSaveSystemTween: Tween = create_tween()
	showSaveSystemTween.tween_property(saveSystem, "offset:y", 0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	showSaveSystemTween.tween_callback(saveSystem.SetActive.bind(true))

func HideSaveSystem():
	var hideSaveSystemTween: Tween = create_tween()
	hideSaveSystemTween.tween_property(saveSystem, "offset:y", -900, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	hideSaveSystemTween.tween_callback(remove_child.bind(saveSystem))

func Bubbles():
	if particles.emitting:
		var newParticles = particles.duplicate()
		add_child(newParticles)
		newParticles.emitting = true
		newParticles.finished.connect(newParticles.queue_free)
	else:
		particles.emitting = true
	AudioPlayer.ins.PlaySound(7, AudioPlayer.SoundType.SFX, 1.2)

enum Event { Auto, Default, Christmas }

var currentEvent: Event

func UpdateEvent():
	SetEvent(currentEvent)

func SetEvent(setEvent: Event):
	currentEvent = setEvent

	if currentEvent == Event.Auto:
		var date: Dictionary = Time.get_date_dict_from_system()
		if date.month == 12:
			currentEvent = Event.Christmas
		else:
			currentEvent = Event.Default

	match currentEvent:
		Event.Default:
			MusicPlayer.ins.SetMusic(0)
		Event.Christmas:
			MusicPlayer.ins.SetMusic(1)

	if currentEvent == Event.Christmas:
		if snowEffect && !snowEffect.is_inside_tree():
			add_child(snowEffect)
			mainMenuSnowEffect.visible = true
	else:
		if snowEffect && snowEffect.is_inside_tree():
			remove_child(snowEffect)
			mainMenuSnowEffect.visible = false