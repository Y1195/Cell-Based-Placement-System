local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- local Silo = require(ReplicatedStorage.Packages.Silo)
-- local PlotsSilo = require(script.Silos.Plots)

-- return {
-- 	State = Silo.combine({
-- 		plots = PlotsSilo,
-- 	}),

-- 	Plots = PlotsSilo,
-- }

local Rodux = require(ReplicatedStorage.Game.Rodux)

local reducer = Rodux.combineReducers({
	plots = require(script.Reducers.Plots),
})

local store = Rodux.Store.new(reducer, {}, {
	Rodux.thunkMiddleware, -- Rodux.loggerMiddleware,
})

return store