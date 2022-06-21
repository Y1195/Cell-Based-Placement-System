local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Loader = require(ReplicatedStorage.Packages.Loader)

Knit.AddControllersDeep(ReplicatedStorage.Game.Controllers)
Loader.LoadChildren(ReplicatedStorage.Game.Components)

Knit.Start()
:andThen(function()
	print("KnitClient Started")
end)
:catch(warn)
