extends Button

class_name DecorButton

var partData: PartData

@export var localMat: Material

func Setup(data: PartData):
	partData = data
	tooltip_text = partData.name
	$Texture.texture = partData.texture
	if partData.colorShader:
		$Texture.material = localMat
		localMat.set_shader_parameter("red_color", partData.defaultRed)
		localMat.set_shader_parameter("green_color", partData.defaultGreen)
		localMat.set_shader_parameter("blue_color", partData.defaultBlue)

func SetMat(setMat: Material = localMat):
	if partData.colorShader:
		$Texture.material = setMat