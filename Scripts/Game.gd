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

var selectedFish: FishData

func _init():
	ins = self

func _ready():
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
	ShowMenu()

func HideMenu():
	mainMenu.SetActive(false)
	var hideMenuTween: Tween = create_tween()
	hideMenuTween.tween_property(mainMenu, "offset:x", -500, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	hideMenuTween.tween_callback(remove_child.bind(mainMenu))

func ShowMenu():
	add_child(mainMenu)
	var showMenuTween: Tween = create_tween()
	showMenuTween.tween_property(mainMenu, "offset:x", 0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	showMenuTween.tween_callback(mainMenu.SetActive.bind(true))

func ShowHUD():
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
	add_child(fishPicker)
	fishPicker.picked = false
	fishPicker.SetFish(-1)
	fishPicker.offset = Vector2(0, 900)
	var showFishPickerTween: Tween = create_tween()
	showFishPickerTween.tween_property(fishPicker, "offset:y", 0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

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
