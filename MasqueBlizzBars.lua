--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by the
-- Free Software Foundation, either version 3 of the License, or (at your
-- option) any later version.
-- 
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
-- more details.
--
-- You should have received a copy of the GNU General Public License along
-- with this program. If not, see <https://www.gnu.org/licenses/>.
--

local MSQ = LibStub("Masque")

local MasqueBlizzBars = {
	MasqueSkin = MasqueSkin or {},
	Groups = {},
	Buttons = {
		ActionBar = {
			ActionButton = NUM_ACTIONBAR_BUTTONS
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
		-- Three new bars for 10.0.0
		MultiBar5 = {
			MultiBar5Button = NUM_MULTIBAR_BUTTONS
		},
		MultiBar6 = {
			MultiBar6Button = NUM_MULTIBAR_BUTTONS
		},
		MultiBar7 = {
			MultiBar7Button = NUM_MULTIBAR_BUTTONS
		},
		PetBar = {
			PetActionButton = NUM_PET_ACTION_SLOTS
		},
		PossessBar = {
			PossessButton = NUM_POSSESS_SLOTS
		},
		-- Since 10.0.0 the value is in the XML frame definition
		StanceBar = {
			StanceButton = StanceBar.numButtons
		},
		-- SpellFlyout always has one button at UI init time
		SpellFlyout = {
			SpellFlyoutButton = 1
		}
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

function MasqueBlizzBars:SpellFlyout_Toggle(flyoutID, ...)
	-- Determine how many buttons the flyout will actually have
	local _, _, numSlots, _ = GetFlyoutInfo(flyoutID)
	local activeSlots = 0
        for slot = 1, numSlots do
		local _, _, isKnown, _, _ = GetFlyoutSlotInfo(flyoutID, slot)
		if (isKnown) then
			activeSlots = activeSlots+1
		end
	end

	-- Skin any extra buttons found
	local numButtons = MasqueBlizzBars.Buttons.SpellFlyout.SpellFlyoutButton
        if (numButtons < activeSlots) then
		for i = numButtons+1, activeSlots do
			MasqueBlizzBars:SkinButton(MasqueBlizzBars.Groups.SpellFlyout, _G["SpellFlyoutButton"..i])
		end
		MasqueBlizzBars.Buttons.SpellFlyout.SpellFlyoutButton = activeSlots
	end
end

function MasqueBlizzBars:Init()
	hooksecurefunc("UIParent_ManageFramePositions", MasqueBlizzBars.UIParent_ManageFramePositions);
	hooksecurefunc(SpellFlyout, "Toggle", MasqueBlizzBars.SpellFlyout_Toggle)
	MSQ:Register("Blizzard Action Bars", MasqueBlizzBars.OnSkinChange, MasqueBlizzBars)

	MasqueBlizzBars.Groups = {
		ActionBar           = MSQ:Group("Blizzard Action Bars", "Action Bar 1"),
		MultiBarBottomLeft  = MSQ:Group("Blizzard Action Bars", "Action Bar 2"),
		MultiBarBottomRight = MSQ:Group("Blizzard Action Bars", "Action Bar 3"),
		MultiBarLeft        = MSQ:Group("Blizzard Action Bars", "Action Bar 4"),
		MultiBarRight       = MSQ:Group("Blizzard Action Bars", "Action Bar 5"),
		MultiBar5           = MSQ:Group("Blizzard Action Bars", "Action Bar 6"),
		MultiBar6           = MSQ:Group("Blizzard Action Bars", "Action Bar 7"),
		MultiBar7           = MSQ:Group("Blizzard Action Bars", "Action Bar 8"),
		PetBar              = MSQ:Group("Blizzard Action Bars", "Pet Bar"),
		PossessBar          = MSQ:Group("Blizzard Action Bars", "Possess Bar"),
		StanceBar           = MSQ:Group("Blizzard Action Bars", "Stance Bar"),
		SpellFlyout         = MSQ:Group("Blizzard Action Bars", "Spell Flyouts"),
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

function MasqueBlizzBars:SkinButton(group, button)
	if button then
		group:AddButton(button)
	end
end

function MasqueBlizzBars:UpdateActionBars()
	for k, v in pairs(MasqueBlizzBars.Groups) do
		for _k, _v in pairs(MasqueBlizzBars.Buttons[k]) do
			if (_v == 0) then
				MasqueBlizzBars:SkinButton(v, _G[_k])
			else
				for i = 1, _v do
					MasqueBlizzBars:SkinButton(v, _G[_k..i])
				end
			end
		end
	end
end

MasqueBlizzBars:Init()
