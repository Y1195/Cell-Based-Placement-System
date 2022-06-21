local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Loader = require(ReplicatedStorage.Packages.Loader)

Knit.AddServicesDeep(ServerStorage.Game.Services)
Loader.LoadChildren(ServerStorage.Game.Components)

Knit.Start()
:andThen(function()
	print("KnitServer Started")
end)
:catch(warn)
