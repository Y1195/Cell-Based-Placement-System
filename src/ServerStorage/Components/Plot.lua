-- Component
-- 0_1195
-- May 07, 2022

--[[



]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Http = game:GetService("HttpService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local GridModules = require(ReplicatedStorage.Game.Shared.Grid)
local State = require(ServerStorage.Game.Modules.State)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local ItemData = require(ReplicatedStorage.Game.Shared.ItemData)
local Sift = require(ReplicatedStorage.Packages.sift)
local PlotConfig = require(ReplicatedStorage.Game.Shared.PlotConfig)
local Grid = GridModules.Grid
local GridUtil = GridModules.GridUtil
local CellObject = GridModules.CellObject

local UPDATE_DELAY = 0.1

local Class = Component.new({
	Tag = "Plot",
	Ancestors = { workspace },
})

function Class:GetOwner()
	local instance: Folder = self.Instance
	local ownerId = instance:GetAttribute("OwnerId")
	local UserService = Knit.GetService("UserService")
	return UserService:GetUserById(ownerId)
end

function Class:SetOwner(user)
	self:ClearOwner()

	local instance: Folder = self.Instance
	instance:SetAttribute("OwnerId", user.Player.UserId)

	State:dispatch({
		type = "SetObjects",
		key = self.Key,
		objects = user.Data.GridObjects,
	})
end

function Class:ClearOwner()
	self.Grid:Clear()
	State:dispatch({
		type = "SetObjects",
		key = self.Key,
		objects = {},
	})
	local instance: Folder = self.Instance
	instance:SetAttribute("OwnerId", nil)
end

function Class:Construct()
	local instance: Folder = self.Instance
	self._janitor = Janitor.new()

	self.Key = Http:GenerateGUID(false)

	local gridModel: Model = instance.Grid
	local origin = gridModel:GetPivot()
	local plotRoot = gridModel.PrimaryPart
	local size = Vector2.new(plotRoot.Size.X, plotRoot.Size.Z)
	local grid = Grid.new(origin, size, PlotConfig.CellSize)
	self.Grid = grid
	self._janitor:Add(function()
		self.Grid:Destroy()
	end)

	State:dispatch({
		type = "SetObjects",
		key = self.Key,
		objects = {},
	})
	self._janitor:Add(function()
		State:dispatch({
			type = "RemovePlot",
			key = self.Key,
		})
	end)

	self._objects = Fusion.State({})
	self._janitor:Add(function()
		self._objects:set({}, true)
	end)

	local computed = Fusion.ComputedPairs(self._objects, function(_index: number, value)
		local itemId, position, rotation = GridUtil.DeserializeCell(value)
		local baseItemData: ItemData.ItemData = ItemData[tonumber(itemId)]

		local gridPositionList = GridUtil.GetGridPositionList(
			baseItemData.Id,
			position,
			GridUtil.Directions[rotation + 1]
		)

		local prefab = baseItemData.Prefab
		prefab = prefab:Clone()
		prefab.PrimaryPart.PivotOffset = CFrame.new(-prefab.PrimaryPart.Size / 2)

		local rotationOffset = GridUtil.GetRotationOffset(baseItemData.Id, GridUtil.Directions[rotation + 1])
		local placedObjectWorldCFrame: CFrame = grid:GetWorldCFrame(position)
			* CFrame.new(Vector3.new(rotationOffset.X, 0, rotationOffset.Y) * grid.cellSize)
			* CFrame.Angles(0, math.pi / 2 * rotation, 0)

		prefab:PivotTo(placedObjectWorldCFrame)
		prefab.PrimaryPart.PivotOffset = CFrame.new(0, -prefab.PrimaryPart.Size / 2, 0)
		-- id is already set
		prefab:SetAttribute("Position", position)
		prefab:SetAttribute("Rotation", rotation)

		local cellObject = CellObject.new(prefab, position, GridUtil.Directions[rotation + 1])
		-- place object in data
		GridUtil.PlaceObjectInGrid(grid, gridPositionList, cellObject)
		return { cellObject, gridPositionList } -- need to return cellObject for parenting
	end, function(data)
		local gridPositionList = data[2]
		-- RemoveObjectFromGrid calls cell:Clear() which calls cellObject:Destroy()
		GridUtil.RemoveObjectFromGrid(grid, gridPositionList)
	end)

	local folder: Folder = Fusion.New("Folder")({
		Name = "Assets",
		Parent = instance,

		[Fusion.Children] = { -- TODO fix not parenting to workspace. Fusion.Instances.Scheduler uses RenderStepped instead of Hearbeat
			Fusion.ComputedPairs(computed, function(_i, data) -- hm, this works
				-- parent object
				local cellObject = data[1]
				local prefab = cellObject:Get()
				return prefab
			end),
		},
	})
	self._janitor:Add(function()
		folder:Destroy()
	end)
	-- watch for plot state
	local updateThread = task.delay(UPDATE_DELAY, function() end)
	local function onChange(newObjects)
		task.cancel(updateThread)
		updateThread = task.delay(UPDATE_DELAY, function()
			self._objects:set(newObjects)
		end)
	end

	local selector = function(state)
		return state.plots[self.Key]
	end

	local value = selector(State:getState())

	self._janitor:Add(State.changed:connect(function(newState, _oldState)
		local newValue = selector(newState)
		if Sift.Array.equalsDeep(newValue, value) then
			return
		end
		value = newValue
		onChange(value)
	end).disconnect)

	onChange(value)
end

function Class:Start() end

function Class:Stop()
	self:ClearOwner()
	self._janitor:Destroy()
end

return Class
