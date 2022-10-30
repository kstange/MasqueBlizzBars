local MSQ = LibStub("Masque")

local MasqueBlizzBars = {
	MasqueSkin = MasqueSkin or {},
	Groups = {}
}

local buttons = {
	ActionBar = {
		ActionButton = NUM_ACTIONBAR_BUTTONS,
		BonusActionButton = NUM_BONUS_ACTION_SLOTS
	},
	MultiBarBottomLeft = {
		MultiBarBottomLeftButton = NUM_MULTIBAR_BUTTONS
	},
	MultiBarBottomRight = {
		MultiBarBottomRightButton = NUM_MULTIBAR_BUTTONS
	},
	MultiBarLeft = {
		MultiBarLeftButton = NUM_MULTIBAR_BUTTONS
	},
	MultiBarRight = {
		MultiBarRightButton = NUM_MULTIBAR_BUTTONS
	},
	PetBar = {
		PetActionButton = NUM_PET_ACTION_SLOTS
	},
	StanceBar = {
		ShapeshiftButton = NUM_SHAPESHIFT_SLOTS,
		PossessButton = NUM_POSSESS_SLOTS,
		StanceButton = NUM_STANCE_SLOTS
	}
}

function MasqueBlizzBars:OnSkinChange(Group, Skin, SkinID, Gloss, Backdrop, Colors)
	if (Group == nil) then
		for k, v in pairs(MasqueBlizzBars.Groups) do
			MasqueBlizzBars:OnSkinChange(v, Skin, SkinID, Gloss, Backdrop, Colors)
		end
		return
	elseif (not MasqueBlizzBars.MasqueSkin[Group]) then
		MasqueBlizzBars.MasqueSkin[Group] = {}
	end
	MasqueBlizzBars.MasqueSkin[Group].Skin = Skin
	MasqueBlizzBars.MasqueSkin[Group].SkinID = SkinID
	MasqueBlizzBars.MasqueSkin[Group].Gloss = Gloss
	MasqueBlizzBars.MasqueSkin[Group].Backdrop = Backdrop
	MasqueBlizzBars.MasqueSkin[Group].Colors = Colors
end

function MasqueBlizzBars:UIParent_ManageFramePositions()
	for k, v in pairs(MasqueBlizzBars.Groups) do
		v:ReSkin()
	end
end

function MasqueBlizzBars:Init()
	hooksecurefunc("UIParent_ManageFramePositions", MasqueBlizzBars.UIParent_ManageFramePositions);
	MSQ:Register("Blizzard Action Bars", MasqueBlizzBars.OnSkinChange, MasqueBlizzBars)

	MasqueBlizzBars.Groups = {
		ActionBar = MSQ:Group("Blizzard Action Bars", "Action Bar"),
		MultiBarBottomLeft = MSQ:Group("Blizzard Action Bars", "MultiBar BottomLeft"),
		MultiBarBottomRight = MSQ:Group("Blizzard Action Bars", "MultiBar BottomRight"),
		MultiBarLeft = MSQ:Group("Blizzard Action Bars", "MultiBar Left"),
		MultiBarRight = MSQ:Group("Blizzard Action Bars", "MultiBar Right"),
		PetBar = MSQ:Group("Blizzard Action Bars", "PetBar"),
		StanceBar = MSQ:Group("Blizzard Action Bars", "StanceBar"),
	}

	if MasqueBlizzBars.MasqueSkin then
		for k, v in pairs(MasqueBlizzBars.Groups) do
			if (MasqueBlizzBars.MasqueSkin[v.Group]) then
				v:SetOption('Group', MasqueBlizzBars.MasqueSkin[v.Group].Group)
				v:SetOption('SkinID', MasqueBlizzBars.MasqueSkin[v.Group].SkinID)
				v:SetOption('Gloss', MasqueBlizzBars.MasqueSkin[v.Group].Gloss)
				v:SetOption('Backdrop', MasqueBlizzBars.MasqueSkin[v.Group].Backdrop)
				v:SetOption('Colors', MasqueBlizzBars.MasqueSkin[v.Group].Colors)
			end
		end
	end

	MasqueBlizzBars:UpdateActionBars()
end

function MasqueBlizzBars:SkinButton(group, button, strata)
	local st = starta or "HIGH"
	if button then
		group:AddButton(button)
		button:SetFrameStrata(st)
	end
end

function MasqueBlizzBars:UpdateActionBars()
	for k, v in pairs(MasqueBlizzBars.Groups) do
		for _k, _v in pairs(buttons[k]) do
			for i = 1, _v do
				MasqueBlizzBars:SkinButton(v, _G[_k..i])
			end
		end
	end
end

MasqueBlizzBars:Init()
