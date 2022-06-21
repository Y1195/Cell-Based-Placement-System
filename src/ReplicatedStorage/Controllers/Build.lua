-- BuildController
-- 0_1195
-- May 11, 2022

--[[



]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Run = game:GetService("RunService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local State = require(ReplicatedStorage.Game.Modules.State)
local UI = require(ReplicatedStorage.Game.Modules.UI)
local ItemData = require(ReplicatedStorage.Game.Shared.ItemData)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Timer = require(ReplicatedStorage.Packages.Timer)
local GridUtil = require(ReplicatedStorage.Game.Shared.Grid).GridUtil
local Sift = require(ReplicatedStorage.Packages.sift)
local RoduxWatcher = require(ReplicatedStorage.Game.Shared.RoduxWatcher)
local PlotController
local PlotService

local PREFAB_SPEED = 15
-- id of items
local items = { 1, 2, 3 }

local adorneeState = Fusion.State()
local canPlaceState = Fusion.State(false)
Fusion.New("Highlight")({
	Adornee = adorneeState,
	DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
	FillColor = Fusion.Computed(function()
		return canPlaceState:get() and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 38, 0)
	end),
	FillTransparency = 0.5,
	OutlineColor = Color3.fromRGB(255, 255, 255),
	OutlineTransparency = 1,
	Parent = workspace.CurrentCamera,
})

local _janitor = Janitor.new()

local watcher = RoduxWatcher(State)

local Controller = Knit.CreateController({
	Name = "BuildController",
})

function Controller:CheckCanPlace(grid: Grid, position: Vector2, id: number): boolean
	local baseItemData: ItemData.ItemData = ItemData[id]

	local buildState = State:getState().build
	local rotation: number = buildState.rotation

	local gridPositionList = GridUtil.GetGridPositionList(baseItemData.Id, position, GridUtil.Directions[rotation + 1])
	return GridUtil.CanPlaceObjectInGrid(grid, gridPositionList)
end

function Controller:StartBuild(itemId: number)
	self:StopBuild()

	local baseItemData: ItemData.ItemData = ItemData[itemId]
	if not baseItemData then
		return
	end

	if PlotController.MyPlot == nil then
		return
	end
	--[[
		does it need to be like this?
		this does keep hotbar state and build state seperate....
		hotbarselected -> dispatch -> watch selected -> dispatch -> watch itemId
	]]
	State:dispatch({
		type = "SetBuild",
		itemId = itemId,
	})
end

function Controller:StopBuild()
	State:dispatch({
		type = "SetBuild",
		itemId = Sift.None,
	})
end

function Controller:_updatePrefabPosition(delta: number)
	debug.profilebegin("UPDATE PREFAB")
	if PlotController.MyPlot == nil then
		return
	end

	local prefab: Model = _janitor:Get("Prefab")
	prefab.PrimaryPart.PivotOffset = CFrame.new(-prefab.PrimaryPart.Size / 2)

	local grid = PlotController.MyPlot.Grid

	local buildState = State:getState().build
	local itemId: number = buildState.itemId

	if itemId == nil then
		return
	end

	local baseItemData: ItemData.ItemData = ItemData[itemId]

	local rotation: number = buildState.rotation
	local rotationOffset = GridUtil.GetRotationOffset(baseItemData.Id, GridUtil.Directions[rotation + 1])
	local position: Vector2 = buildState.position
	local placedObjectWorldCFrame: CFrame = grid:GetWorldCFrame(position)
		* CFrame.new(Vector3.new(rotationOffset.X, 0, rotationOffset.Y) * grid.cellSize)
		* CFrame.Angles(0, math.pi / 2 * rotation, 0)

	local goal = prefab:GetPivot():Lerp(placedObjectWorldCFrame, delta * PREFAB_SPEED)
	prefab:PivotTo(goal)
	debug.profileend()
end

function Controller:KnitStart()
	-- populate hotbar
	State:dispatch({
		type = "SetItems",
		items = items,
	})
	-- inputs
	local InputController = Knit.GetController("InputController")
	for i = 1, 9 do
		InputController:Add(string.format("Hotbar%i", i), function()
			State:dispatch({
				type = "SetSelected",
				selected = i,
			})
		end)
	end
	InputController:Add("Rotate", function()
		local buildState = State:getState().build
		local itemId: number = buildState.itemId

		if itemId == nil then
			return
		end

		local rotation: number = buildState.rotation
		State:dispatch({
			type = "SetRotation",
			rotation = (rotation + 1) % #GridUtil.Directions,
		})
	end)
	InputController:Add("Activate", function() -- TODO delete tool/mode
		if PlotController.MyPlot == nil then
			return
		end

		local state = State:getState()

		local buildState = state.build
		local itemId: number = buildState.itemId

		if itemId == nil then
			return
		end

		local canPlace: boolean = buildState.canPlace
		if not canPlace then
			return
		end

		local rotation: number = buildState.rotation
		local position: Vector2 = buildState.position
		local serialized = GridUtil.SerializeCell(itemId, position, rotation)
		-- update plot
		State:dispatch({
			type = "AddObject",
			serialized = serialized,
		})
		-- tell the server
		PlotService.PlaceObject:Fire(itemId, position, rotation)

		-- update data for client
		local dataState = state.data
		State:dispatch({
			type = "SetPlayerData",
			key = "GridObjects",
			value = Sift.Array.push(dataState.GridObjects, serialized),
		})
	end)
	-- every 1/10 second check which grid position mouse is in
	Timer.Simple(1 / 10, function()
		if PlotController.MyPlot == nil then
			return
		end

		local ignore = { _janitor:Get("Prefab") }
		for _, v in Players:GetPlayers() do
			table.insert(ignore, v.Character)
		end

		local castResult = InputController:CastInWorld(100, ignore)
		local raycastResult: RaycastResult = castResult.raycastResult
		local cframe = CFrame.new(castResult.Origin + castResult.Direction)
		if raycastResult then
			cframe = CFrame.new(raycastResult.Position)
		end

		local grid = PlotController.MyPlot.Grid
		local position: Vector2 = grid:GetXY(cframe)

		State:dispatch({
			type = "SetPosition",
			position = position,
		})

		local itemId = State:getState().build.itemId
		if itemId ~= nil then
			local canPlace = self:CheckCanPlace(grid, position, itemId)
			State:dispatch({
				type = "SetCanPlace",
				canPlace = canPlace,
			})
		end
	end, false, Run.RenderStepped)
end

function Controller:KnitInit()
	PlotController = Knit.GetController("PlotController")
	PlotService = Knit.GetService("PlotService")

	local function itemIdChanged(id: number)
		local baseItemData: ItemData.ItemData = ItemData[id]
		local prefab = baseItemData.Prefab
		prefab = prefab:Clone()
		_janitor:Add(prefab, nil, "Prefab")
		for _, part: BasePart in prefab:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
		end

		Run:UnbindFromRenderStep("UpdatePrefabPosition") -- just in case
		Run:BindToRenderStep("UpdatePrefabPosition", Enum.RenderPriority.Camera.Value, function(delta: number)
			self:_updatePrefabPosition(delta)
		end)
		_janitor:Add(function()
			adorneeState:set(nil)
			Run:UnbindFromRenderStep("UpdatePrefabPosition")
		end)

		self:_updatePrefabPosition(1 / PREFAB_SPEED)
		adorneeState:set(prefab)

		prefab.Parent = workspace.CurrentCamera
	end
	-- this has to go before watching hotbar.selected otherwise it will bug out. TODO fix?
	do
		watcher(function(state)
			return state.build.itemId
		end, function(itemId)
			if itemId == nil then
				_janitor:Cleanup()
			else
				itemIdChanged(itemId)
			end
		end)
	end

	local function selectedChanged(slot: number)
		if slot == nil then
			self:StopBuild()
		else
			local itemId: number = items[slot]
			self:StartBuild(itemId)
		end
	end

	local selectedSlot = Fusion.State()
	-- watch for hotbar selected
	do
		watcher(function(state)
			return state.hotbar.selected
		end, function(selected)
			selectedSlot:set(selected)
			selectedChanged(selected)
		end)
	end
	-- watch for hotbar items
	local hotbarItems = Fusion.State({})
	do
		local function onChange(newItems)
			hotbarItems:set(newItems)
		end

		local function selector(state)
			return state.hotbar.items
		end

		local value = selector(State:getState())

		State.changed:connect(function(newState, _oldState)
			local newValue = selector(newState)
			if Sift.Array.equalsDeep(newValue, value) then
				return
			end
			value = newValue
			onChange(value)
		end)

		onChange(value)
	end
	-- watch for canPlace
	do
		watcher(function(state)
			return state.build.canPlace
		end, function(canPlace)
			canPlaceState:set(canPlace)
		end)
	end
	-- create hotbar ui
	local hotbarFrame: Frame = UI.Hotbar({
		hotbarItems = hotbarItems,
		selectedSlot = selectedSlot,
		onSelected = function(i)
			State:dispatch({
				type = "SetSelected",
				selected = i,
			})
		end,
	})
	hotbarFrame.Parent = UI.Gui
end

return Controller
