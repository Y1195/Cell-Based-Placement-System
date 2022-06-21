local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rodux = require(ReplicatedStorage.Game.Rodux)
local Sift = require(ReplicatedStorage.Packages.sift)

local initialState = {
	itemId = nil,

	rotation = 0,
	position = Vector2.new(0, 0),

	canPlace = false,

	mode = "build",
}

local reducer = Rodux.createReducer(initialState, {
	SetBuild = function(state, action)
		return Sift.Dictionary.merge(state, {
			itemId = action.itemId,
		})
	end,

	SetRotation = function(state, action)
		return Sift.Dictionary.merge(state, {
			rotation = action.rotation,
		})
	end,

	SetPosition = function(state, action)
		return Sift.Dictionary.merge(state, {
			position = action.position,
		})
	end,

	SetCanPlace = function(state, action)
		return Sift.Dictionary.merge(state, {
			canPlace = action.canPlace,
		})
	end,
})

return reducer
