local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rodux = require(ReplicatedStorage.Game.Rodux)
local Sift = require(ReplicatedStorage.Packages.sift)

local initialState = {
	preferredInput = "Keyboard",
}

local reducer = Rodux.createReducer(initialState, {
	SetPreferred = function(state, action)
		return Sift.Dictionary.merge(state, {
			preferredInput = action.preferredInput,
		})
	end,
})

return reducer
