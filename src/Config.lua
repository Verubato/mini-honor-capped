local addonName, addon = ...
---@type MiniFramework
local mini = addon.Framework

mini:WaitForAddonLoad(function()
	-- A styled button clashes with the stock Blizzard art around it in the settings screen.
	mini:SetCustomStyling(true, { Button = false })

	local panel = CreateFrame("Frame")
	panel.name = addonName

	local category = mini:AddCategory(panel)

	if not category then
		return
	end

	local header = mini:PanelHeader({
		Parent = panel,
		Description = "Prints a message to chat when you are almost honor capped.",
		Divider = true,
	})

	local thresholdSlider = mini:Slider({
		Parent = panel,
		LabelText = "Warning Threshold",
		Min = 0,
		Max = addon.MaxHonor,
		Step = 100,
		GetValue = function()
			-- MiniHonorCapped.lua sets addon.Db from its own ADDON_LOADED handler, which can
			-- run after this panel is built, so fall back to the default until it exists.
			return (addon.Db and addon.Db.HonorThreshold) or addon.DbDefaults.HonorThreshold
		end,
		SetValue = function(value)
			addon.Db.HonorThreshold = mini:ClampInt(value, 0, addon.MaxHonor, addon.DbDefaults.HonorThreshold)
		end,
	})

	-- A slider carries its label above the track, so it needs a double gap under a section
	-- rule where a checkbox would only need one.
	thresholdSlider.Slider:SetPoint("TOPLEFT", header.Divider, "BOTTOMLEFT", 0, -mini.VerticalSpacing * 2)

	mini:RegisterSlashCommand(category, panel, {
		"/minihonorcapped",
		"/mhc",
	})
end)
