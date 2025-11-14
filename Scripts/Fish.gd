extends CanvasGroup

class_name Fish

func SwapFish(fishId: int, updateSelected: bool = true):
	if updateSelected:
		Game.ins.selectedFish = Game.ins.fishDataList[fishId]
	$FishBody.texture = Game.ins.fishDataList[fishId].texture

	if updateSelected:
		match fishId:
			0:
				Game.ins.kisses.position = Vector2(965, 304)
			1:
				Game.ins.kisses.position = Vector2(965, 264)
			2:
				Game.ins.kisses.position = Vector2(933, 137)
			3:
				Game.ins.kisses.position = Vector2(965, 264)
			4:
				Game.ins.kisses.position = Vector2(929, 308)
			5:
				Game.ins.kisses.position = Vector2(932, 321)
			6:
				Game.ins.kisses.position = Vector2(932, 321)
			7:
				Game.ins.kisses.position = Vector2(932, 336)