-- Loads the whole addon into a mocked client and drives it through login.
-- The shared body lives in build/Lua/SmokeTest.lua.

local fw = require("TestFramework")
local smoke = require("SmokeTest")
local WowMock = require("WowMock")

---The header's subtitle is built by the framework and never handed back to the addon, so a
---test finds it the way a player reads it, by its words.
---@param text string
---@return boolean
local function HasText(text)
	for _, frame in ipairs(WowMock.Frames) do
		if frame.GetText and frame:GetText() == text then
			return true
		end

		for _, region in ipairs({ frame:GetRegions() }) do
			if region.GetText and region:GetText() == text then
				return true
			end
		end
	end

	return false
end

local VERTICAL_SPACING = 16

---The section rule is built by the framework and never handed back to the addon, so a test
---finds it the way a player sees it, by its label.
---@param text string
---@return table?
local function FindDivider(text)
	for _, frame in ipairs(WowMock.Frames) do
		if frame.Label and frame.Label.GetText and frame.Label:GetText() == text then
			return frame
		end
	end
end

---@return table?
local function FindSlider()
	for _, frame in ipairs(WowMock.Frames) do
		if frame:GetObjectType() == "Slider" then
			return frame
		end
	end
end

smoke.Run("MiniHonorCapped", {
	extra = function(context)
		fw.eq(context.Addon.Framework.CustomStyling, true, "custom styling on")
		fw.eq(context.Addon.Framework.CustomStylingOverrides.Button, false, "stock buttons")
		fw.truthy(HasText("Prints a message to chat when you are almost honor capped."), "the subtitle under the panel title")

		local divider = FindDivider("SETTINGS")
		fw.not_nil(divider, "the settings section rule under the header")

		local slider = FindSlider()
		fw.not_nil(slider, "the warning threshold slider")

		local _, sliderAnchor, _, sliderX, sliderY = slider:GetPoint()
		fw.eq(sliderAnchor, divider, "the threshold slider anchors to the section divider")
		fw.eq(sliderX, 0, "the threshold slider has no horizontal offset")
		fw.eq(sliderY, -VERTICAL_SPACING * 2, "a slider needs a double gap since its label sits above the track")
	end,
})
