-- PlotController
-- 0_1195
-- May 13, 2022

--[[

is there a better way to get current plot for localplayer?

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local State = require(ReplicatedStorage.Game.Modules.State)
local RoduxWatcher = require(ReplicatedStorage.Game.Shared.RoduxWatcher)

local watcher = RoduxWatcher(State)

local Controller = Knit.CreateController({
	Name = "PlotController",

	MyPlot = nil,
})

function Controller:KnitStart() end

function Controller:KnitInit()
	watcher(function(state)
		return state.data.GridObjects
	end, function(gridObjects)
		State:dispatch({
			type = "SetObjects",
			objects = gridObjects,
		})
	end)
end

return Controller
