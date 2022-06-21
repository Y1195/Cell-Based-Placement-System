local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rodux = require(ReplicatedStorage.Game.Rodux)
local Sift = require(ReplicatedStorage.Packages.sift)

local initialState = {
	items = {},
	selected = nil,
}

local reducer = Rodux.createReducer(initialState, {
	SetSelected = function(state, action)
		local currentSelected = state.selected
		local i = action.selected
		local selected = (currentSelected == i) and Sift.None or i
		return Sift.Dictionary.merge(state, {
			selected = selected,
		})
	end,

	SetItems = function(state, action)
		return Sift.Dictionary.merge(state, {
			items = action.items,
		})
	end,
})

return reducer
