-- ScaleController
-- 0_1195
-- May 08, 2022

--[[

https://devforum.roblox.com/t/scaler-using-uiscale-to-scale-your-ui/1105672

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local State = require(ReplicatedStorage.Game.Modules.State)

local MULTIPLIER = 1 / 720
local DISPATCH_DELAY = 0.5

local camera = workspace.CurrentCamera

local Controller = Knit.CreateController({
	Name = "ScaleController",
})

function Controller:KnitStart() end

function Controller:KnitInit()
	local updateThread = task.delay(DISPATCH_DELAY, function() end)

	local function viewportSizeChanged()
		local viewportSize = camera.ViewportSize

		local sizeX, sizeY = viewportSize.X, viewportSize.Y
		local scale = MULTIPLIER * sizeY

		if sizeY > sizeX then
			scale = MULTIPLIER * sizeX
		end

		task.cancel(updateThread)
		updateThread = task.delay(DISPATCH_DELAY, function()
			State:dispatch({
				type = "SetScale",
				scale = scale,
			})
		end)
	end

	task.spawn(viewportSizeChanged)

	camera:GetPropertyChangedSignal("ViewportSize"):Connect(viewportSizeChanged)
end

return Controller
