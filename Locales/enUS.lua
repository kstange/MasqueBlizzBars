--
-- Masque Blizzard Bars
--
-- Locales\enUS.lua -- enUS Localization File
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

-- Please use CurseForge to submit localization content for another language:
-- https://www.curseforge.com/wow/addons/masque-blizz-bars-revived/localization

local Locale = GetLocale()
-- allow enUS to fill empty strings for other locales
--if Locale ~= "enUS" then return end

local _, Shared = ...
local L = Shared.Locale

-- Defaults for these are the keys themselves
--L["Action Bar 1"] = "Action Bar 1"
--L["Action Bar 2"] = "Action Bar 2"
--L["Action Bar 3"] = "Action Bar 3"
--L["Action Bar 4"] = "Action Bar 4"
--L["Action Bar 5"] = "Action Bar 5"
--L["Action Bar 6"] = "Action Bar 6"
--L["Action Bar 7"] = "Action Bar 7"
--L["Action Bar 8"] = "Action Bar 8"
--L["Pet Bar"] = "Pet Bar"
--L["Possess Bar"] = "Possess Bar"
--L["Stance Bar"] = "Stance Bar"
--L["Spell Flyouts"] = "Spell Flyouts"
--L["Vehicle Bar"] = "Vehicle Bar"
--L["Extra Ability Buttons"] = "Extra Ability Buttons"
--L["Pet Battle Bar"] = "Pet Battle Bar"

-- Using short keys for these long strings, so enUS needs to be defined as well
L["NOTES_SPELL_FLYOUTS"] = "This group includes all flyouts shown anywhere in the game, such as Action Bars and the Spellbook."
L["NOTES_VEHICLE_BAR"] = "This bar is shown when you enter a vehicle with abilities. The exit button is not currently able to be skinned."
L["NOTES_EXTRA_ABILITY_BUTTONS"] = "This group includes the Extra Action Button shown during encounters and quests, and all Zone Ability Buttons shown for location-based abilities.\n\nSome buttons have additional background images framing them, so square skins tend to work best."
