extends CanvasLayer

var menuActive: bool = true

func StartButton():
	if !menuActive:
		return
	Game.ins.HideMenu()
	var delay: Tween = create_tween()
	delay.tween_interval(0.5)
	delay.tween_callback(Game.ins.ShowFish)
	delay.tween_callback(Game.ins.ShowFishPicker)

func SettingsButton():
	if !menuActive:
		return
	Game.ins.ShowSettings()

func SetActive(value: bool):
	menuActive = value

func ExitButton():
	if !menuActive:
		return
	get_tree().quit()