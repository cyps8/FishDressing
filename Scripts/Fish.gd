extends CanvasGroup

class_name Fish

func SwapFish(fishId: int, updateSelected: bool = true):
	if updateSelected:
		Game.ins.selectedFish = Game.ins.fishDataList[fishId]
	$FishBody.texture = Game.ins.fishDataList[fishId].texture