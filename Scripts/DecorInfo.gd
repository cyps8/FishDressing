extends Resource

class_name DecorInfo

var id: int
var position: Vector2
var rotation: float
var scale: float

var flippedH: bool
var flippedV: bool

var colourR: Color
var colourG: Color
var colourB: Color

var belowFish: bool

func _init(itemId, pos, rot, sca, flipH, flipV, colR, colG, colB, below):
	id = itemId
	position = pos
	rotation = rot
	scale = sca
	flippedH = flipH
	flippedV = flipV
	colourR = colR
	colourG = colG
	colourB = colB
	belowFish = below