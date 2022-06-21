-- Class
-- 0_1195
-- May 06, 2022

--[[

keep data and the player object seperate

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local Class = {}
Class.__index = Class

function Class.__tostring(self)
	return tostring(self.Player.UserId)
end

function Class:UpdateData(key: string, callback: (any) -> (any), forceUpdate: boolean?)
	local currentData = self.Data[key]
	local newData = callback(currentData)

	self.Profile.Data[key] = newData
	self.Data[key] = newData

	Knit.GetService("DataService"):DataChanged(self, key, newData, forceUpdate)
end

function Class.new(player: Player)
	local self = setmetatable({
		Player = player,

		Profile = nil,
		Data = nil,

		_janitor = Janitor.new(),
	}, Class)

	return self
end

function Class:Destroy()
	self._janitor:Destroy()
end

return Class
