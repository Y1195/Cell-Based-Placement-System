-- DataService
-- 0_1195
-- May 06, 2022

--[[



]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local ProfileService = require(ServerStorage.Game.Modules.ProfileService)
local DataTemplate = require(ReplicatedStorage.Game.Shared.DataTemplate)
local Promise = require(ReplicatedStorage.Packages.Promise)
local UserService

local PROFILE_STORE_NAME = "PlayerData"

local profileStore = ProfileService.GetProfileStore(PROFILE_STORE_NAME, DataTemplate)

local Service = Knit.CreateService({
	Name = "DataService",
	Client = {
		DataChanged = Knit.CreateSignal(),
	},
})

function Service.Client:RequestData(player: Player)
	local dataInited = player:GetAttribute("_dataInited")
	if dataInited == true then
		return nil
	end

	return Promise.retryWithDelay(function()
		return Promise.new(function(resolve, reject)
			local user = UserService:GetUser(player)
			if user then
				resolve(user)
			else
				reject()
			end
		end)
	end, 10, 1)
		:andThen(function(user)
			player:SetAttribute("_dataInited", true)
			return user.Data
		end)
		:catch()
		:expect()
end

function Service:LoadProfile(player: Player)
	local dataKey = "Player_" .. tostring(player.UserId)
	local profile = profileStore:LoadProfileAsync(dataKey)

	if not profile then
		UserService:Kick(player, "Roblox DataStore Down")
		return nil
	end

	if not player:IsDescendantOf(Players) then
		profile:Release()
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()
	profile:ListenToRelease(function()
		-- dont use UserService:Kick() here
		player:Kick()
	end)

	return profile
end

function Service:DataChanged(user, key: string, value: string, forceUpdate: boolean?)
	if forceUpdate then
		warn(string.format("FORCE UPDATE %s FOR %s", key, tostring(user)))
		self.Client.DataChanged:Fire(user.Player, key, value)
	end

	if key == "" then
		print(value)
	end
end

function Service:KnitStart() end

function Service:KnitInit()
	UserService = Knit.GetService("UserService")
end

return Service
