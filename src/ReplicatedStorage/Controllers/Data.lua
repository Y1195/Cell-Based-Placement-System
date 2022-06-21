-- DataController
-- 0_1195
-- May 06, 2022

--[[



]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Http = game:GetService("HttpService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local State = require(ReplicatedStorage.Game.Modules.State)
local Sift = require(ReplicatedStorage.Packages.sift)
local Signal = require(ReplicatedStorage.Packages.Signal)

local Controller = Knit.CreateController({
	Name = "DataController",

	DataChanged = Signal.new(),
})

function Controller:KnitStart() end

function Controller:KnitInit()
	local function dataChanged(key, value)
		if value == nil then
			value = Sift.None
		end

		State:dispatch({
			type = "SetPlayerData",
			key = key,
			value = value,
		})

		self.DataChanged:Fire(key, value)

		print(string.format("Got new player data %s: %s", key, Http:JSONEncode(value)))
	end

	local DataService = Knit.GetService("DataService")
	DataService
		:RequestData()
		:andThen(function(data)
			for k, v in data do
				dataChanged(k, v)
			end
		end)
		:catch(warn)

	DataService.DataChanged:Connect(dataChanged)
end

return Controller
