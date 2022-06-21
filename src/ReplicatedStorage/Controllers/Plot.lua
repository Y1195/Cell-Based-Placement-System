-- PlotController
-- 0_1195
-- May 13, 2022

--[[

is there a better way to get current plot for localplayer?

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local State = require(ReplicatedStorage.Game.Modules.State)

local Controller = Knit.CreateController({
	Name = "PlotController",

	MyPlot = nil,
})

function Controller:KnitStart()
	local DataController = Knit.GetController("DataController")

	-- feels jank
	DataController.DataChanged:Connect(function(key, value)
		if key == "GridObjects" then
			if self.MyPlot == nil then
				return
			end

			State:dispatch({
				type = "SetObjects",
				objects = value,
			})
		end
	end)
end

function Controller:KnitInit() end

return Controller
