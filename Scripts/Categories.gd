extends TabBar

func _ready():
	tab_hovered.connect(Callable(_Focused))

func _Focused(_i: int):
	AudioPlayer.ins.PlaySound(1)