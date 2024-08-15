export type Code = {
	RedeemTimes: number,
	ExpirationTime: number,
	Redeemers: {number},
}

export type CodeVault = {
	Codes: {[string]: Code},
	new: () -> CodeVault,
	GenerateCode: (self: CodeVault, codeStr: string, redeemTimes: number?, expirationTime: number?) -> Code,
	RedeemCode: (self: CodeVault, plr: Player, codeStr: string) -> (boolean, string),
	DeleteCode: (self: CodeVault, codeStr: string) -> (),
	IsCodeExpired: (self: CodeVault, codeStr: string) -> boolean,
	GetCodeInfo: (self: CodeVault, codeStr: string) -> (boolean, Code?),
	GetRemainingRedeemTimes: (self: CodeVault, codeStr: string) -> (boolean, number?),
	ClearExpiredCodes: (self: CodeVault) -> number,
	_SaveCodes: (self: CodeVault) -> (),
	_LoadCodes: (self: CodeVault) -> (),
	UpdateCodeDetails: (self: CodeVault, codeStr: string, redeemTimes: number?, expirationTime: number?) -> (boolean, string),
	ListCodes: (self: CodeVault) -> {[string]: {RedeemTimes: number, ExpirationTime: number}},
	CountTotalCodes: (self: CodeVault) -> number,
	GetRedeemersList: (self: CodeVault, codeStr: string) -> (boolean, {number}?),
}

local CodeVault = {}
CodeVault.__index = CodeVault

local DataStoreService = game:GetService("DataStoreService")
local CodeDataStore = DataStoreService:GetDataStore("CodeVaultDataStore")

function CodeVault.new(): CodeVault
	local self = setmetatable({
		Codes = {},
	}, CodeVault)
	self:_LoadCodes()
	return self
end

function CodeVault:GenerateCode(codeStr: string, redeemTimes: number?, expirationTime: number?): Code
    if self.Codes[codeStr] then
        warn("Code already exists: " .. codeStr)
        return self.Codes[codeStr]
    end
    local code: Code = {
        RedeemTimes = redeemTimes or -1,
        ExpirationTime = expirationTime or -1,
        Redeemers = {},
    }
    self.Codes[codeStr] = code
    self:_SaveCodes()
    return code
end


function CodeVault:RedeemCode(plr: Player, codeStr: string): (boolean, string)
	local code = self.Codes[codeStr]
	if not code then return false, "Invalid code." end
	if code.ExpirationTime ~= -1 and tick() > code.ExpirationTime then return false, "Code has expired." end
	if code.RedeemTimes ~= -1 and #code.Redeemers >= code.RedeemTimes then return false, "Code fully redeemed." end
	if table.find(code.Redeemers, plr.UserId) then return false, "Already redeemed." end
	table.insert(code.Redeemers, plr.UserId)
	self:_SaveCodes()
	return true, "Code redeemed successfully!"
end

function CodeVault:DeleteCode(codeStr: string)
	if self.Codes[codeStr] then
		self.Codes[codeStr] = nil
		self:_SaveCodes()
	end
end

function CodeVault:IsCodeExpired(codeStr: string): boolean
	local code = self.Codes[codeStr]
	return code and code.ExpirationTime ~= -1 and tick() > code.ExpirationTime or false
end

function CodeVault:GetCodeInfo(codeStr: string): (boolean, Code?)
	return self.Codes[codeStr] ~= nil, self.Codes[codeStr]
end

function CodeVault:GetRemainingRedeemTimes(codeStr: string): (boolean, number?)
	local code = self.Codes[codeStr]
	if not code then return false, nil end
	return true, code.RedeemTimes == -1 and math.huge or (code.RedeemTimes - #code.Redeemers)
end

function CodeVault:ClearExpiredCodes(): number
	local count = 0
	for codeStr, code in pairs(self.Codes) do
		if self:IsCodeExpired(codeStr) then
			self.Codes[codeStr] = nil
			count += 1
		end
	end
	if count > 0 then self:_SaveCodes() end
	return count
end

function CodeVault:_SaveCodes()
	local success, errorMessage = pcall(function()
		CodeDataStore:SetAsync("Codes", self.Codes)
	end)
	if not success then warn("Failed to save codes:", errorMessage) end
end

function CodeVault:_LoadCodes()
	local success, data = pcall(function()
		return CodeDataStore:GetAsync("Codes")
	end)
	self.Codes = success and data or {}
end

function CodeVault:UpdateCodeDetails(codeStr: string, redeemTimes: number?, expirationTime: number?): (boolean, string)
	local code = self.Codes[codeStr]
	if not code then return false, "Code not found." end
	code.RedeemTimes = redeemTimes or code.RedeemTimes
	code.ExpirationTime = expirationTime or code.ExpirationTime
	self:_SaveCodes()
	return true, "Code details updated."
end

function CodeVault:ListCodes(): {[string]: {RedeemTimes: number, ExpirationTime: number}}
	local list = {}
	for codeStr, code in pairs(self.Codes) do
		list[codeStr] = {
			RedeemTimes = code.RedeemTimes,
			ExpirationTime = code.ExpirationTime,
		}
	end
	return list
end

function CodeVault:CountTotalCodes(): number
	return #self.Codes
end

function CodeVault:GetRedeemersList(codeStr: string): (boolean, {number}?)
	local code = self.Codes[codeStr]
	if not code then return false, nil end
	return true, code.Redeemers
end

return CodeVault
