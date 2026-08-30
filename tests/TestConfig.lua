-- Exercises how Config.lua wires the threshold slider to the framework: the slider's own
-- options are local to its WaitForAddonLoad callback, so a spy on the framework catches them
-- as Config.lua builds the panel.

local fw = require("TestFramework")
local harness = require("AddonHarness")

---Wraps mini:Slider so the options table Config.lua passes it is captured before the real
---call runs.
---@param framework table
---@return table[] calls
local function SpySlider(framework)
	local calls = {}
	local original = framework.Slider

	framework.Slider = function(self, options)
		calls[#calls + 1] = options
		return original(self, options)
	end

	return calls
end

---Loads the addon with the slider spy already in place, then logs in so Config.lua builds
---the panel and MiniHonorCapped.lua's own ADDON_LOADED handler runs.
---@return table context
---@return table sliderOptions the single Slider() call Config.lua makes
local function BuildContext()
	-- harness.Load preserves declared saved variables across its own install, which models a
	-- /reload but would otherwise leak one test's HonorThreshold write into the next test's load.
	_G.MiniHonorCappedDB = nil

	local context = harness.Load("MiniHonorCapped")
	local sliders = SpySlider(context.Addon.Framework)

	harness.Login(context)

	return context, sliders[1]
end

fw.describe("MiniHonorCapped - Config panel", function()
	fw.it("falls back to the default before the db exists", function()
		local context, slider = BuildContext()

		context.Addon.Db = nil

		fw.eq(slider.GetValue(), context.Addon.DbDefaults.HonorThreshold, "falls back to the default")
	end)

	fw.it("reads the saved threshold", function()
		local context, slider = BuildContext()

		context.Addon.Db.HonorThreshold = 7000

		fw.eq(slider.GetValue(), 7000, "slider reads the saved threshold")
	end)

	fw.it("writes a new threshold back", function()
		local context, slider = BuildContext()

		slider.SetValue(9000)

		fw.eq(context.Addon.Db.HonorThreshold, 9000, "slider writes the new threshold")
	end)
end)
