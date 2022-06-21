local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rodux = require(ReplicatedStorage.Game.Rodux)
local Sift = require(ReplicatedStorage.Packages.sift)

local initialState = {}

local reducer = Rodux.createReducer(initialState, {
	NewPlot = function(state, action)
		return Sift.Dictionary.merge(state, {
			[action.key] = action.objects,
		})
	end,

	RemovePlot = function(state, action)
		return Sift.Dictionary.merge(state, {
			[action.key] = Sift.None,
		})
	end,

	SetObjects = function(state, action)
		local newState = Sift.Dictionary.merge(state, {
			[action.key] = action.objects,
		})
		return newState
	end,

	AddObject = function(state, action)
		return Sift.Dictionary.mergeDeep(state, {
			[action.key] = Sift.Array.push(state[action.key], action.serialized),
		})
	end,

	RemoveObject = function(state, action)
		return Sift.Dictionary.mergeDeep(state, {
			[action.key] = Sift.Array.removeValue(state[action.key], action.serialized),
		})
	end,
})

return reducer
