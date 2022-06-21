local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- local Silo = require(ReplicatedStorage.Packages.Silo)
-- local DataSilo = require(script.Silos.Data)
-- local ScaleSilo = require(script.Silos.Scale)
-- local HotbarSilo = require(script.Silos.Hotbar)
-- local InputSilo = require(script.Silos.Input)
-- local BuildSilo = require(script.Silos.Build)
-- local PlotSilo =  require(script.Silos.Plot)

-- return {
-- 	State = Silo.combine({
-- 		data = DataSilo,
-- 		scale = ScaleSilo,
-- 		hotbar = HotbarSilo,
-- 		input = InputSilo,
-- 		build = BuildSilo,
-- 		plot = PlotSilo,
-- 	}, {}),

-- 	Data = DataSilo,
-- 	Scale = ScaleSilo,
-- 	Hotbar = HotbarSilo,
-- 	Input = InputSilo,
-- 	Build = BuildSilo,
-- 	Plot = PlotSilo,
-- }

local Rodux = require(ReplicatedStorage.Game.Rodux)

local reducer = Rodux.combineReducers({
	build = require(script.Reducers.Build),
	data = require(script.Reducers.Data),
	hotbar = require(script.Reducers.Hotbar),
	input = require(script.Reducers.Input),
	plot = require(script.Reducers.Plot),
	scale = require(script.Reducers.Scale),
})

local store = Rodux.Store.new(reducer, {}, {
	Rodux.thunkMiddleware, --Rodux.loggerMiddleware,
})

return store
