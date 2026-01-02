local addonName, _ = ...
local frame
local db
local dbDefaults = {
	HonorThreshold = 13000,
	TextFormat = "|cffff0000Almost honor capped! (%s / 15000)|r",
}
local lastWarningAmount

local function CopyTable(src, dst)
	if type(dst) ~= "table" then
		dst = {}
	end

	for k, v in pairs(src) do
		if type(v) == "table" then
			dst[k] = CopyTable(v, dst[k])
		elseif dst[k] == nil then
			dst[k] = v
		end
	end

	return dst
end

local function GetHonorAmount()
	if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
		local possibleIds = { 1901, 1792, 392 }
		for _, id in ipairs(possibleIds) do
			local info = C_CurrencyInfo.GetCurrencyInfo(id)
			if info and info.quantity then
				return info.quantity
			end
		end
	end

	if GetHonorCurrency then
		local v = GetHonorCurrency()
		if type(v) == "number" then
			return v
		end
	end

	return nil
end

local function Run()
	local honor = GetHonorAmount()

	if not honor then
		return
	end

	local honorThreshold = db.HonorThreshold or dbDefaults.HonorThreshold
	local textFormat = db.TextFormat or dbDefaults.TextFormat
	local msg = textFormat:format(honor)

	if honor >= honorThreshold and honor ~= lastWarningAmount then
		print(msg)
		lastWarningAmount = honor
	end
end

local function Init()
	MiniHonorCappedDB = MiniHonorCappedDB or {}
	db = CopyTable(dbDefaults, MiniHonorCappedDB)
end

frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(_, event, arg1)
	if event == "ADDON_LOADED" and arg1 == addonName then
		Init()

		frame:UnregisterEvent("ADDON_LOADED")
		frame:RegisterEvent("PLAYER_ENTERING_WORLD")
		frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
		frame:SetScript("OnEvent", Run)
	end
end)
