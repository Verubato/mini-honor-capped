-- MaxHonor moved from a saved setting to a constant on the addon table, but a player who
-- logged in before that change still has the old key sitting in their saved table.

local fw = require("TestFramework")
local harness = require("AddonHarness")
local WowMock = require("WowMock")

fw.describe("MiniHonorCapped - MaxHonor constant", function()
	fw.it("is no longer a saved default", function()
		local context = harness.Load("MiniHonorCapped")
		harness.Login(context)

		fw.no_key(context.Addon.DbDefaults, "MaxHonor", "dbDefaults.MaxHonor")
	end)

	fw.it("clears a stale MaxHonor left by an earlier login", function()
		WowMock.Install()
		_G.MiniHonorCappedDB = { MaxHonor = 15000 }

		local context = harness.Load("MiniHonorCapped", { install = false })
		harness.Login(context)

		fw.is_nil(_G.MiniHonorCappedDB.MaxHonor, "stale MaxHonor")
	end)
end)
