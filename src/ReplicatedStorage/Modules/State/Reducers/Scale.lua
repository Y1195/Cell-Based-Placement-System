local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rodux = require(ReplicatedStorage.Game.Rodux)
local Sift = require(ReplicatedStorage.Packages.sift)

local initialState = {
	scale = 1,
}

local reducer = Rodux.createReducer(initialState, {
	SetScale = function(state, action)
		return Sift.Dictionary.merge(state, {
			scale = action.scale,
		})
	end,
})

return reducer
