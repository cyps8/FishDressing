extends Control

func _ready():
	mouse_entered.connect(Callable(_Focused))

func _Focused():
	AudioPlayer.ins.PlaySound(1)