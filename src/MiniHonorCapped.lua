local addonName, _ = ...
local frame
local db
local dbDefaults = {
	HonorThreshold = 13000,
	MaxHonor = 15000,
	AlmostCappedFormat = "|cffff0000You're almost honor capped! (%s / 15000)|r",
	CappedFormat = "|cffff0000You're honor capped!|r",
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

local function Run(forcePrint)
	local honor = GetHonorAmount()

	if not honor then
		return
	end

	local textFormat

	if honor >= (db.MaxHonor or dbDefaults.MaxHonor) then
		textFormat = db.CappedFormat or dbDefaults.CappedFormat
	elseif honor >= (db.HonorThreshold or dbDefaults.HonorThreshold) then
		textFormat = db.AlmostCappedFormat or dbDefaults.AlmostCappedFormat
	else
		return
	end

	local msg = textFormat:format(honor)

	if forcePrint or honor ~= lastWarningAmount then
		print(msg)
		lastWarningAmount = honor
	end
end

local function OnEvent(_, event)
	Run(event == "PLAYER_ENTERING_WORLD")
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
		frame:SetScript("OnEvent", OnEvent)
	end
end)
