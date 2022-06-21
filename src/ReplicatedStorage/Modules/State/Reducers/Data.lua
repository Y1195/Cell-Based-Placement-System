local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rodux = require(ReplicatedStorage.Game.Rodux)
local Sift = require(ReplicatedStorage.Packages.sift)
local DataTemplate = require(ReplicatedStorage.Game.Shared.DataTemplate)

local initialState = Sift.Dictionary.copyDeep(DataTemplate)

local reducer = Rodux.createReducer(initialState, {
	SetPlayerData = function(state, action)
		return Sift.Dictionary.merge(state, {
			[action.key] = action.value,
		})
	end,
})

return reducer
