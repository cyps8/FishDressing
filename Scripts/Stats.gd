extends Label

func UpdateStats():
    text = "Fish: " + str(SteamManager.ins.GetFishDressed()) + "\n" + "Kisses: " + str(SteamManager.ins.GetFishKissed()) + "\n" + "Parts: " + str(SteamManager.ins.GetPartsCreated())