ITEM.name = "PDA"
ITEM.model = "models/ethprops/handhelds/pda.mdl"
ITEM.price = 2000
ITEM.weight = 0.25
ITEM.img = Material("stalker/ui/devices/pda_icon.png")

function ITEM:GetDescription()
	return "A PDA that encourages long range communication between individuals. Being the newest version of the PDA series, this allows the user to both select an avatar, but also select their own username." .. "\n\nAvatar: " .. self:GetData("avatar","stalker/ui/avatars/nodata.png") .. "\n\nPDA handle: " .. self:GetData("username", "meme")
end