extends Node2D

class_name Game

static var ins: Game

var mainMenu: CanvasLayer

var hud: CanvasLayer

var fish: CanvasGroup

var fishPicker: CanvasLayer

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

func HideMenu():
	var hideMenuTween: Tween = create_tween()
	hideMenuTween.tween_property(mainMenu, "offset:x", -500, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	hideMenuTween.tween_callback(remove_child.bind(mainMenu))

func ShowMenu():
	add_child(mainMenu)
	var showMenuTween: Tween = create_tween()
	showMenuTween.tween_property(mainMenu, "offset:x", 0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func ShowHUD():
	add_child(hud)
	hud.offset = Vector2(0, 900)
	var showHUDTween: Tween = create_tween()
	showHUDTween.tween_property(hud, "offset:y", 0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func HideHUD():
	var hideHUDTween: Tween = create_tween()
	hideHUDTween.tween_property(hud, "offset:y", 900, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	hideHUDTween.tween_callback(remove_child.bind(hud))

func ShowFish():
	add_child(fish)
	fish.position = Vector2(0, 900)
	var showFishTween: Tween = create_tween()
	showFishTween.tween_property(fish, "position:y", 0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func HideFish():
	var hideFishTween: Tween = create_tween()
	hideFishTween.tween_property(fish, "position:y", 900, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	hideFishTween.tween_callback(remove_child.bind(fish))

func ShowFishPicker():
	add_child(fishPicker)
	fishPicker.offset = Vector2(0, 900)
	var showFishPickerTween: Tween = create_tween()
	showFishPickerTween.tween_property(fishPicker, "offset:y", 0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func HideFishPicker():
	var hideFishPickerTween: Tween = create_tween()
	hideFishPickerTween.tween_property(fishPicker, "offset:y", 900, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	hideFishPickerTween.tween_callback(remove_child.bind(fishPicker))