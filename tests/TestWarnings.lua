-- Drives the warning through the real event path: fake the currency quantity, fire the
-- update event the addon listens for, and read what it printed.

local fw = require("TestFramework")
local harness = require("AddonHarness")
local WowMock = require("WowMock")

---@param quantity number
local function SetHonor(quantity)
	_G.C_CurrencyInfo.GetCurrencyInfo = function()
		return { quantity = quantity }
	end
end

fw.describe("MiniHonorCapped - warnings", function()
	fw.it("warns at the threshold and again at the cap", function()
		local context = harness.Load("MiniHonorCapped")
		harness.Login(context)

		local threshold = context.Addon.Db.HonorThreshold
		local cap = context.Addon.MaxHonor

		SetHonor(threshold)
		WowMock.FireEvent("CURRENCY_DISPLAY_UPDATE")
		fw.eq(#WowMock.State.Prints, 1, "warns once the threshold is reached")
		fw.truthy(WowMock.State.Prints[1]:find("almost", 1, true), "the threshold message reads almost capped")

		SetHonor(cap)
		WowMock.FireEvent("CURRENCY_DISPLAY_UPDATE")
		fw.eq(#WowMock.State.Prints, 2, "warns again once fully capped")
		fw.falsy(WowMock.State.Prints[2]:find("almost", 1, true), "the cap message reads fully capped, not almost")
	end)

	fw.it("moves the warning point when the threshold setting changes", function()
		local context = harness.Load("MiniHonorCapped")
		harness.Login(context)

		context.Addon.Db.HonorThreshold = 100

		SetHonor(100)
		WowMock.FireEvent("CURRENCY_DISPLAY_UPDATE")
		fw.eq(#WowMock.State.Prints, 1, "the new threshold fires the warning")

		SetHonor(99)
		WowMock.FireEvent("CURRENCY_DISPLAY_UPDATE")
		fw.eq(#WowMock.State.Prints, 1, "below the new threshold stays quiet")
	end)
end)
