-- Component
-- 0_1195
-- May 06, 2022

--[[



]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Streamable = require(ReplicatedStorage.Packages.Streamable).Streamable
local GridModules = require(ReplicatedStorage.Game.Shared.Grid)
local State = require(ReplicatedStorage.Game.Modules.State)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local ItemData = require(ReplicatedStorage.Game.Shared.ItemData)
local Sift = require(ReplicatedStorage.Packages.sift)
local Grid = GridModules.Grid
local GridUtil = GridModules.GridUtil
local CellObject = GridModules.CellObject

local Class = Component.new({
	Tag = "Plot",
	Ancestors = { workspace },
})

function Class:IsLocalPlayerPlot(): boolean
	local instance: Model = self.Instance
	local ownerId: number = instance:GetAttribute("OwnerId")
	return ownerId == Knit.Player.UserId
end

function Class:StartForLocalPlayer()
	self:StopForLocalPlayer()

	local localJanitor = self._janitor:Get("LocalJanitor")

	local instance: Model = self.Instance
	-- StreamingEnabled compatable, hopefully
	local primaryStreamable = Streamable.primary(instance.Grid)
	localJanitor:Add(primaryStreamable)
	primaryStreamable:Observe(function(primaryPart)
		primaryPart.Color = Color3.fromRGB(48, 216, 112)
	end)

	local gridModel: Model = instance.Grid
	local origin = gridModel:GetPivot()
	local plotRoot = gridModel.PrimaryPart
	local size = Vector2.new(plotRoot.Size.X, plotRoot.Size.Z)
	local grid = Grid.new(origin, size, 4)
	self.Grid = grid
	localJanitor:Add(function()
		self.Grid:Destroy()
	end)

	self._objects = Fusion.State({})
	localJanitor:Add(function()
		self._objects:set({}, true)
	end)
	-- needs to be indexed or it will not work?
	self.Computed = Fusion.ComputedPairs(self._objects, function(_index: number, value)
		local itemId, position, rotation = GridUtil.DeserializeCell(value)
		local baseItemData: ItemData.ItemData = ItemData[tonumber(itemId)]

		local cellObject = CellObject.new(baseItemData.Id, position, GridUtil.Directions[rotation + 1])
		local gridPositionList = GridUtil.GetGridPositionList(
			baseItemData.Id,
			position,
			GridUtil.Directions[rotation + 1]
		)
		GridUtil.PlaceObjectInGrid(grid, gridPositionList, cellObject)
		return gridPositionList
	end, function(gridPositionList)
		GridUtil.RemoveObjectFromGrid(grid, gridPositionList)
	end)
	localJanitor:Add(function()
		self.Computed = nil
	end)
	-- watch for objects
	local function onChange(objects)
		self._objects:set(objects)
	end

	local selector = function(state)
		return state.plot
	end

	local value = selector(State:getState())

	localJanitor:Add(State.changed:connect(function(newState, _oldState)
		local newValue = selector(newState)
		if Sift.Array.equalsDeep(newValue, value) then
			return
		end
		value = newValue
		onChange(value)
	end).disconnect)

	onChange(value)
	-- set plot
	local PlotController = Knit.GetController("PlotController")
	PlotController.MyPlot = self
	localJanitor:Add(function()
		PlotController.MyPlot = nil
	end)
end

function Class:StopForLocalPlayer()
	local localJanitor = self._janitor:Get("LocalJanitor")

	local primaryStreamable = Streamable.primary(self.Instance.Grid)
	localJanitor:Add(primaryStreamable)
	primaryStreamable:Observe(function(primaryPart)
		primaryPart.Color = Color3.fromRGB(255, 0, 255)
	end)
	localJanitor:Cleanup()
end

function Class:Construct()
	local instance = self.Instance
	self._janitor = Janitor.new()

	local localJanitor = Janitor.new()
	self._janitor:Add(localJanitor, nil, "LocalJanitor")
	-- only want to start the component for localplayer
	local function ownerIdChanged()
		local ownerId: number = instance:GetAttribute("OwnerId")
		if ownerId == Knit.Player.UserId then
			self:StartForLocalPlayer()
		else
			self:StopForLocalPlayer()
		end
	end

	task.spawn(ownerIdChanged)

	self._janitor:Add(instance:GetAttributeChangedSignal("OwnerId"):Connect(ownerIdChanged))
end

function Class:Start() end

function Class:Stop()
	self:StopForLocalPlayer()
	self._janitor:Destroy()
end

return Class
