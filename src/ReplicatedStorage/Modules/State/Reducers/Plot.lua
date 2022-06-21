local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rodux = require(ReplicatedStorage.Game.Rodux)
local Sift = require(ReplicatedStorage.Packages.sift)
local DataTemplate = require(ReplicatedStorage.Game.Shared.DataTemplate)

local initialState = Sift.Dictionary.copy(DataTemplate.GridObjects)

local reducer = Rodux.createReducer(initialState, {
	SetObjects = function(_state, action)
		return Sift.Array.copyDeep(action.objects)
	end,

	AddObject = function(state, action)
		return Sift.Array.push(state, action.serialized)
	end,

	RemoveObject = function(state, action)
		return Sift.Array.removeValue(state, action.serialized)
	end,
})

return reducer
