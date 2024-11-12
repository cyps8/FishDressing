extends Node

class_name SaveMan

static var ins: SaveMan

var saves: Array[Save]

var activeSave: Save

var iconCap: SubViewport
var iconFish: Fish

func _init():
	ins = self

func _ready():
	iconCap = $IconCapture
	iconFish = $IconCapture/Fish

	await FindSaves()

func NewSave():
	var save = Save.new()
	save.id = GetNumber()
	if Editor.ins.nameEdit.text == "":
		save.name = Game.ins.selectedFish.name
	else:
		save.name = Editor.ins.nameEdit.text
	save.fishId = Game.ins.fishDataList.find(Game.ins.selectedFish)
	save.saveState = Editor.ins.currentState
	save.saveIcon = await MakeIcon(save)
	img.save_png("user://fishpng" + str(save.id) + ".png")
	saves.append(save)
	CreateFishFile(save)
	activeSave = save

func UpdateSave():
	activeSave.saveState = Editor.ins.currentState
	activeSave.saveIcon = await MakeIcon(activeSave)
	DirAccess.remove_absolute("user://fishpng" + str(activeSave.id) + ".png")
	img.save_png("user://fishpng" + str(activeSave.id) + ".png")
	DirAccess.remove_absolute("user://fishsave" + str(activeSave.id) + ".save")
	CreateFishFile(activeSave)

func DeleteSave(i: int):
	DirAccess.remove_absolute("user://fishpng" + str(saves[i].id) + ".png")
	DirAccess.remove_absolute("user://fishsave" + str(saves[i].id) + ".save")
	saves.remove_at(i)

func GetNumber() -> int:
	var num = -1
	var fine = false
	while !fine:
		num += 1
		fine = true
		for save in saves:
			if save.id == num:
				fine = false
	return num

func LoadSave(file: Save):
	activeSave = file
	Game.ins.LoadSave()

func SwapFish():
	Game.ins.fish.SwapFish(activeSave.fishId)

func LoadFish():
	Editor.ins.nameEdit.text = activeSave.name
	Editor.ins.LoadState(activeSave.saveState)

func FindSaves():
	var dir = DirAccess.open("user://")
	dir.list_dir_begin()
	var file = dir.get_next()
	while file != "":
		if file.begins_with("fishsave"):
			await OpenFishFile(file.get_file())
		file = dir.get_next()

func OpenFishFile(file: String):
	var saveFile = FileAccess.open("user://" + file, FileAccess.READ)
	var save = Save.new()
	save.id = saveFile.get_16()
	var nameLength = saveFile.get_8()
	save.name = saveFile.get_buffer(nameLength).get_string_from_utf8()
	save.fishId = saveFile.get_8()
	var partCount = int(saveFile.get_16())
	var newState = SaveState.new()
	for i in range(partCount):
		var newInfo = DecorInfo.new(saveFile.get_8(), Vector2(saveFile.get_float(), saveFile.get_float()), saveFile.get_float(), saveFile.get_float(), saveFile.get_8() == 1, saveFile.get_8() == 1, Color(saveFile.get_float(), saveFile.get_float(), saveFile.get_float()), Color(saveFile.get_float(), saveFile.get_float(), saveFile.get_float()), Color(saveFile.get_float(), saveFile.get_float(), saveFile.get_float()), saveFile.get_8() == 1)
		newState.parts.append(newInfo)
	save.saveState = newState
	if FileAccess.file_exists("user://fishpng" + str(save.id) + ".png"):
		img = Image.load_from_file("user://fishpng" + str(save.id) + ".png")
		save.saveIcon = ImageTexture.create_from_image(img)
	else:
		save.saveIcon = await MakeIcon(save)
		img.save_png("user://fishpng" + str(save.id) + ".png")
	saves.append(save)

func CreateFishFile(save: Save):
	var saveFile = FileAccess.open("user://fishsave" + str(save.id) + ".save", FileAccess.WRITE)
	saveFile.store_16(save.id)
	saveFile.store_8(save.name.length())
	saveFile.store_string(save.name)
	saveFile.store_8(save.fishId)
	saveFile.store_16(save.saveState.parts.size())
	for part in save.saveState.parts:
		saveFile.store_8(part.id)
		saveFile.store_float(part.position.x)
		saveFile.store_float(part.position.y)
		saveFile.store_float(part.rotation)
		saveFile.store_float(part.scale)
		saveFile.store_8(part.flippedH as int)
		saveFile.store_8(part.flippedV as int)
		saveFile.store_float(part.colourR.r)
		saveFile.store_float(part.colourR.g)
		saveFile.store_float(part.colourR.b)
		saveFile.store_float(part.colourG.r)
		saveFile.store_float(part.colourG.g)
		saveFile.store_float(part.colourG.b)
		saveFile.store_float(part.colourB.r)
		saveFile.store_float(part.colourB.g)
		saveFile.store_float(part.colourB.b)
		saveFile.store_8(part.belowFish as int)

var img: Image

func MakeIcon(save: Save) -> Texture:
	iconFish.SwapFish(save.fishId, false)
	LoadIconState(save.saveState)
	await RenderingServer.frame_post_draw
	img = iconCap.get_texture().get_image()
	CropSticker()
	return ImageTexture.create_from_image(img)

func CropSticker():
	for i in range(4):
		img.rotate_90(CLOCKWISE)
		var data = img.get_data()
		var amountToCrop: int = 0
		while !FindPixels(data, amountToCrop + 125):
			amountToCrop += 125
		while !FindPixels(data, amountToCrop + 50):
			amountToCrop += 50
		while !FindPixels(data, amountToCrop + 25):
			amountToCrop += 25
		while !FindPixels(data, amountToCrop + 10):
			amountToCrop += 10
		img.rotate_180()
		img.crop((img.get_width()) as int, img.get_height() - amountToCrop as int)
		img.rotate_180()

func FindPixels(data, amount: int = 0) -> bool:
	var skipTo: int = img.get_width() * 4 * amount
	for i in img.get_width():
		if data[(4 * i) + 3 + skipTo] > 0:
			return true
	return false

func LoadIconState(state: SaveState):
	DeleteAll()
	var i: int = 0
	for part in state.parts:
		InstaCreateNewDecor(part, i)
		i += 1

func DeleteAll():
	var toDelete: Array[Part] = []
	for child in iconFish.get_children():
		if child is Part:
			toDelete.append(child)
	while toDelete.size() > 0:
		toDelete[0].queue_free()
		toDelete.remove_at(0)

func InstaCreateNewDecor(info: DecorInfo, belowLayer: int = 0):
	var newDecor = Editor.ins.partIns.instantiate() as Part
	newDecor.id = info.id
	newDecor.partData = Editor.ins.partDataList[info.id]
	newDecor.SetTexture(Editor.ins.partDataList[info.id].texture)
	newDecor.SetColors(info.colourR, info.colourG, info.colourB)
	newDecor.position = info.position / 2
	newDecor.rotation = info.rotation
	newDecor.scale = Vector2(info.scale / 2, info.scale / 2)
	newDecor.flip_h = info.flippedH
	newDecor.flip_v = info.flippedV
	iconFish.add_child(newDecor)
	if info.belowFish:
		iconFish.move_child(newDecor, belowLayer)
