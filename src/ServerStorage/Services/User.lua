-- UserService
-- 0_1195
-- May 06, 2022

--[[



]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local Service = Knit.CreateService({
	Name = "UserService",
	Client = {},

	Users = {},

	UserAdded = Signal.new(),
	UserRemoving = Signal.new(),
})

function Service:Observe(userAdded: () -> (), userRemoving: () -> ())
	local janitor = Janitor.new()
	for _, user in self.Users do
		task.spawn(userAdded, user)
	end
	janitor:Add(self.UserAdded:Connect(userAdded))
	janitor:Add(self.UserRemoving:Connect(userRemoving))
	return janitor
end

function Service:GetUser(player: Player)
	return self.Users[player]
end

function Service:GetUserById(userId: number)
	for player: Player, user in self.Users do
		if player.UserId == userId then
			return user
		end
	end
	return nil
end

function Service:GetUsers()
	return self.Users
end

function Service:Kick(player: Player, reason: string)
	warn(string.format("Kicking %d", player.UserId))
	player:Kick(reason)
end

function Service:KnitStart() end

function Service:KnitInit()
	local DataService = Knit.GetService("DataService")
	local User = require(ServerStorage.Game.Modules.User)

	local function playerAdded(player: Player)
		local user = User.new(player)

		local playerProfile = DataService:LoadProfile(player)
		if not playerProfile then
			self:Kick(player, "Roblox DataStore Down")
			return
		end

		user.Profile = playerProfile
		user.Data = playerProfile.Data

		user._janitor:Add(function()
			playerProfile:Release()
		end)

		if player:IsDescendantOf(Players) then
			self.Users[player] = user
			self.UserAdded:Fire(user)
		else
			user:Destroy()
		end
	end

	local function playerRemoving(player: Player)
		local user = self.Users[player]
		if not user then
			return
		end

		warn(string.format("Player %d leaving game", player.UserId))

		self.UserRemoving:Fire(user)
		user:Destroy()
		self.Users[player] = nil
	end

	for _, player in Players:GetPlayers() do
		task.spawn(playerAdded, player)
	end

	Players.PlayerAdded:Connect(playerAdded)
	Players.PlayerRemoving:Connect(playerRemoving)
end

return Service
