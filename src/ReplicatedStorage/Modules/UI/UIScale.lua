local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local State = require(ReplicatedStorage.Game.Modules.State)
local RoduxWatcher = require(ReplicatedStorage.Game.Shared.RoduxWatcher)

local watcher = RoduxWatcher(State)

local scaleState = Fusion.State(1)

watcher(function(state)
	return state.scale.scale
end, function(scale)
	scaleState:set(scale)
end)

return function()
	return Fusion.New("UIScale")({
		Scale = Fusion.Computed(function()
			return scaleState:get()
		end),
	})
end
