extends Node2D

class_name Game

static var ins: Game

var mainMenu: CanvasLayer

var hud: CanvasLayer

func _init():
	ins = self

func _ready():
	mainMenu = $MainMenu
	mainMenu.visible = true

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
	