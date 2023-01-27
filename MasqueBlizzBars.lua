--
-- Masque Blizzard Bars
-- Enables Masque to skin the built-in WoW action bars
--
-- Copyright 2022-23 SimGuy
-- Copyright 2020 Madnessbox
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

local _, Shared = ...
local L = Shared.Locale

local _, _, _, ver = GetBuildInfo()

-- Title will be used for the group name shown in Masque
-- Delayed indicates this group will be deferred to a hook or event
-- Notes will be displayed (if provided) in the Masque settings UI
-- Versions specifies which WoW clients this group supports:
--  To match it must be >= low and < high.
--  High number is the first interface unsupported
-- Buttons should contain a list of frame names with an integer value
--  If -1, assume to be a singular button with that name
--  If  0, this is a dynamic frame to be skinned later
--  If >0, attempt to loop through frames with the name prefix suffixed with
--  the integer range
-- State can be used for storing information about special buttons
local MasqueBlizzBars = {
	Groups = {
		ActionBar = {
			Title = "Action Bar 1",
			Buttons = {
				ActionButton = NUM_ACTIONBAR_BUTTONS
			}
		},
		MultiBarBottomLeft = {
			Title = "Action Bar 2",
			Versions = { 10300, nil },
			Buttons = {
				MultiBarBottomLeftButton = NUM_MULTIBAR_BUTTONS
			}
		},
		MultiBarBottomRight = {
			Title = "Action Bar 3",
			Versions = { 10300, nil },
			Buttons = {
				MultiBarBottomRightButton = NUM_MULTIBAR_BUTTONS
			}
		},
		MultiBarLeft = {
			Title = "Action Bar 4",
			Versions = { 10300, nil },
			Buttons = {
				MultiBarLeftButton = NUM_MULTIBAR_BUTTONS
			}
		},
		MultiBarRight = {
			Title = "Action Bar 5",
			Versions = { 10300, nil },
			Buttons = {
				MultiBarRightButton = NUM_MULTIBAR_BUTTONS
			}
		},
		-- Three new bars for 10.0.0
		MultiBar5 = {
			Title = "Action Bar 6",
			Versions = { 100000, nil },
			Buttons = {
				MultiBar5Button = NUM_MULTIBAR_BUTTONS
			}
		},
		MultiBar6 = {
			Title = "Action Bar 7",
			Versions = { 100000, nil },
			Buttons = {
				MultiBar6Button = NUM_MULTIBAR_BUTTONS
			}
		},
		MultiBar7 = {
			Title = "Action Bar 8",
			Versions = { 100000, nil },
			Buttons = {
				MultiBar7Button = NUM_MULTIBAR_BUTTONS
			}
		},
		PetBar = {
			Title = "Pet Bar",
			Buttons = {
				PetActionButton = NUM_PET_ACTION_SLOTS
			}
		},
		PossessBar = {
			Title = "Possess Bar",
			Buttons = {
				PossessButton = NUM_POSSESS_SLOTS
			}
		},
		StanceBar = {
			Title = "Stance Bar",
			Buttons = {
				-- Static value in game code is not a global
				StanceButton = 10
			}
		},
		SpellFlyout = {
			Title = "Spell Flyouts",
			Notes = L["NOTES_SPELL_FLYOUTS"],
			Versions = { 70003, nil },
			Buttons = {
				SpellFlyoutButton = 0
			}
		},
		OverrideActionBar = {
			Title = "Vehicle Bar",
			Notes = L["NOTES_VEHICLE_BAR"],
			Versions = { 30002, nil },
			Buttons = {
				-- Static value in game code is not a global
				OverrideActionBarButton = 6

				-- Exit Button loses its icon if skinned, so
				-- it's not included here
			}
		},
		ExtraAbilityContainer = {
			Title = "Extra Ability Buttons",
			Notes = L["NOTES_EXTRA_ABILITY_BUTTONS"],
			Versions = { 40300, nil },

			-- Keep track of the frames that have been processed
			State = {
				ExtraActionButton = false,
				ZoneAbilityButton = {}
			},
			Buttons = {
				-- These buttons exist until the first time
				-- they're used so we'll pick them up later
			}
		},
		PetBattleFrame = {
			Title = "Pet Battle Bar",
			Versions = { 50004, nil },
			State = {
				PetBattleButton = {}
			},
			Buttons = {
				-- These buttons are all children of
				-- PetBattleFrame.BottomFrame but some don't
				-- exist or have defined names until the first
				-- battle
			}
		}
	}
}

-- Handle events for buttons that get created dynamically by Blizzard
function MasqueBlizzBars:HandleEvent(event, target)
	-- Handle ExtraActionButton on Extra ActionBar updates
	--
	-- We don't handle the ZAB here because if EAB and ZAB are both
	-- active, the ZAB will get added after the event fires and get
	-- missed.
	if event == "UPDATE_EXTRA_ACTIONBAR" then
		local bar = MasqueBlizzBars.Groups.ExtraAbilityContainer
		local eab = ExtraActionButton1

		-- Make sure the EAB exists and hasn't already been added
		if not bar.State.ExtraActionButton and eab and
		   eab:GetObjectType() == "CheckButton" then
			bar.Group:AddButton(eab)
			bar.State.ExtraActionButton = true
		end

	-- Handle Pet Battle Buttons on Pet Battle start
	elseif event == "PET_BATTLE_OPENING_START" then
		local bar = MasqueBlizzBars.Groups.PetBattleFrame
		local pbf = _G["PetBattleFrame"]["BottomFrame"]

		-- Find the Pet Battle Frame children that are buttons
		-- but only skin the ones that haven't already been seen
		for i = 1, select("#", pbf:GetChildren()) do
			local pbb = select(i, pbf:GetChildren())
			if type(pbb) == "table" and pbb.GetObjectType then
				local name = pbb:GetDebugName()
				local obj = pbb:GetObjectType()
				if bar.State.PetBattleButton[name] ~= pbb and
				   (obj == "CheckButton" or obj == "Button") then
					-- Define the regions for this weird button
					local pbbRegions = {
						Icon = pbb.Icon,
						Count = pbb.Count,
						Cooldown = nil, -- These buttons have no cooldown frame
						Normal = pbb.NormalTexture,
						Highlight = pbb:GetHighlightTexture()
					}
					bar.Group:AddButton(pbb, pbbRegions)
					bar.State.PetBattleButton[name] = pbb
				end
			end
		end
	end
end

-- Spell Flyout buttons are created as needed when a flyout is opened, so
-- check for any new buttons any time that happens
function MasqueBlizzBars:SpellFlyout_Toggle(flyoutID, ...)
	local _, _, numSlots, _ = GetFlyoutInfo(flyoutID)
	local activeSlots = 0
        for slot = 1, numSlots do
		local _, _, isKnown, _, _ = GetFlyoutSlotInfo(flyoutID, slot)
		if (isKnown) then
			activeSlots = activeSlots + 1
		end
	end

	-- Skin any extra buttons found
	local bar = MasqueBlizzBars.Groups.SpellFlyout
	local numButtons = bar.Buttons.SpellFlyoutButton
        if (numButtons < activeSlots) then
		for i = numButtons + 1, activeSlots do
			bar.Group:AddButton(_G["SpellFlyoutButton"..i])
		end
		bar.Buttons.SpellFlyoutButton = activeSlots
	end
end

-- Attempt to adopt the ZoneAbilityButton, which has no name, when Blizzard
-- tries to update the displayed buttons. We do this here because when
-- UPDATE_EXTRA_ACTIONBAR is fired and both EAB and ZAB are active, it will
-- fire too early, the ZAB won't exist, and we'll miss it completely.
function MasqueBlizzBars:ZoneAbilityFrame_UpdateDisplayedZoneAbilities()
	local zac = ZoneAbilityFrame.SpellButtonContainer
	local bar = MasqueBlizzBars.Groups.ExtraAbilityContainer

	for i = 1, select("#", zac:GetChildren()) do
		local zab = select(i, zac:GetChildren())

		-- Try not to add buttons that are already added
		--
		-- I'm not sure if the Frame created for the ZAB is used for
		-- the whole life of the UI so if the frame changes, we'll
		-- skin whatever replaced it.
		if zab and zab:GetObjectType() == "Button" then
			local name = zab:GetDebugName()
			if bar.State.ZoneAbilityButton[name] ~= zab then

				-- Define the regions for this weird button
				local zabRegions = {
					Icon = zab.Icon,
					Count = zab.Count,
					Cooldown = zab.Cooldown,
					Normal = zab.NormalTexture,
					Highlight = zab:GetHighlightTexture()
				}

				bar.Group:AddButton(zab, zabRegions, "Action")
				bar.State.ZoneAbilityButton[name] = zab
			end
		end
	end
end

-- Skin any buttons in the table as members of the given Masque group.
-- If parent is set, then the button names are children of the parent
-- table. The buttons value can be a nested table.
function MasqueBlizzBars:Skin(buttons, group, parent)
	if not parent then parent = _G end
	for button, children in pairs(buttons) do
		if (type(children) == "table") then
			if parent[button] then
				--print('recurse:', button, parent[button])
				MasqueBlizzBars:Skin(children, group, parent[button])
			end
		else
			-- If -1, assume button is the actual button name
			if children == -1 then
				--print("button:", button, children, parent[button])
				group:AddButton(parent[button])

			-- Otherwise, append the range of numbers to the name
			elseif children > 0 then
				for i = 1, children do
					--print("button:", button, children, parent[button..i])
					group:AddButton(parent[button..i])
				end
			end
		end
	end
end

-- Check if the current interface version is between the low number (inclusive)
-- and the high number (exclusive) for implementations that are dependent upon
-- client version.
function MasqueBlizzBars:CheckVersion(versions)
	if not versions or
	   (versions and
	    (not versions[1] or ver >= versions[1]) and
	    (not versions[2] or ver <  versions[2])
	   ) then
		return true
	else
		return false
	end
end

function MasqueBlizzBars:Init()
	-- Hook functions to skin elusive buttons

	-- Spell Flyout
	if MasqueBlizzBars:CheckVersion({ 70003, nil }) then
		hooksecurefunc(SpellFlyout, "Toggle",
		               MasqueBlizzBars.SpellFlyout_Toggle)
	end

	-- Zone Ability Buttons
	-- This may be DraenorZoneAbilityFrame_Update if Classic reaches WoD
	-- This may be ZoneAbilityFrame_Update if Classic reaches Legion
	if MasqueBlizzBars:CheckVersion({ 90001, nil }) then
		hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities",
		               MasqueBlizzBars.ZoneAbilityFrame_UpdateDisplayedZoneAbilities)
	end

	-- Capture events to skin elusive buttons
	MasqueBlizzBars.Events = CreateFrame("Frame")

	-- Extra Action Button
	if MasqueBlizzBars:CheckVersion({ 40300, nil }) then
		MasqueBlizzBars.Events:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")
	end

	-- Pet Battles
	if MasqueBlizzBars:CheckVersion({ 50004, nil }) then
		MasqueBlizzBars.Events:RegisterEvent("PET_BATTLE_OPENING_START")
	end

	MasqueBlizzBars.Events:SetScript("OnEvent", MasqueBlizzBars.HandleEvent)

	-- Create groups for each defined button group and add any buttons
	-- that should exist at this point
	for id, cont in pairs(MasqueBlizzBars.Groups) do
		if MasqueBlizzBars:CheckVersion(cont.Versions) then
			cont.Group = MSQ:Group("Blizzard Action Bars", cont.Title, id)
			-- Reset l10n group names after ensuring migration to Static IDs
			cont.Group:SetName(L[cont.Title])
			if cont.Init then
				cont.Init(cont.Buttons)
			end
			if cont.Notes then
				cont.Group.Notes = cont.Notes
			end
			if not cont.Delayed then
				MasqueBlizzBars:Skin(cont.Buttons, cont.Group)
			end
		end
	end
end

MasqueBlizzBars:Init()
