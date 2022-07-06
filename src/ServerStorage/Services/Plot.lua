-- PlotService
-- 0_1195
-- May 07, 2022

--[[



]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Run = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Plot = require(ServerStorage.Game.Components.Plot)
local ItemData = require(ReplicatedStorage.Game.Shared.ItemData)
local GridModules = require(ReplicatedStorage.Game.Shared.Grid)
local State = require(ServerStorage.Game.Modules.State)
local Sift = require(ReplicatedStorage.Packages.sift)
local PlotConfig = require(ReplicatedStorage.Game.Shared.PlotConfig)
local GridUtil = GridModules.GridUtil
local UserService

local Service = Knit.CreateService({
	Name = "PlotService",
	Client = {
		PlaceObject = Knit.CreateSignal(),
	},
})

function Service:GetPlotForUser(user)
	for _, plot in Plot:GetAll() do
		if plot:GetOwner() == user then
			return plot
		end
	end
	return nil
end

function Service:GetEmptyPlot()
	for _, plot in Plot:GetAll() do
		if not plot:GetOwner() then
			return plot
		end
	end
	return nil
end

function Service:AwaitEmptyPlot(): Promise.Static
	return Promise.new(function(resolve, _reject, onCancel)
		local heartbeat

		local function done()
			heartbeat:Disconnect()
		end

		local function update()
			local plot = self:GetEmptyPlot()
			if plot then
				done()
				resolve(plot)
			end
		end

		onCancel(done)

		heartbeat = Run.Heartbeat:Connect(update)
	end)
end

function Service:KnitStart()
	local function userAdded(user)
		self
			:AwaitEmptyPlot()
			:timeout(30)
			:andThen(function(plot)
				plot:SetOwner(user)
			end)
			:catch(function(err)
				if Promise.Error.isKind(err, Promise.Error.Kind.TimedOut) then
					UserService:Kick(user.Player, "Failed to find empty plot")
				else
					warn(err)
				end
			end)
	end

	local function userRemoving(user)
		local plot = self:GetPlotForUser(user)
		if plot then
			plot:ClearOwner()
		end
	end

	UserService:Observe(userAdded, userRemoving)
end

function Service:KnitInit()
	UserService = Knit.GetService("UserService")

	local function requestPlaceObject(plot, id: number, position: Vector2, rotation: number)
		-- check valid item
		local baseItemData = ItemData[id]
		if not baseItemData then
			return { success = false, error = "Attempted to place invalid item" }
		end
		-- client is trying to place a valid object at a position
		local grid = plot.Grid
		local gridPositionList = GridUtil.GetGridPositionList(
			baseItemData.Id,
			position,
			GridUtil.Directions[rotation + 1]
		)
		local canPlace = GridUtil.CanPlaceObjectInGrid(grid, gridPositionList)
		if not canPlace then
			return {
				success = false,
				error = "Attempted to place item at invalid position",
			}
		end
		-- client can place
		return { success = true }
	end

	self.Client.PlaceObject:Connect(function(player: Player, id: number, position: Vector2, rotation: number)
		-- check is user is loaded
		local user = UserService:GetUser(player)
		if not user then
			UserService:Kick(player, "Data not loaded")
			return
		end
		-- check if user has a plot
		local plot = self:GetPlotForUser(user)
		if not plot then
			return
		end
		-- type checks
		assert(typeof(id) == "number", "")
		assert(typeof(position) == "Vector2", "")
		assert(typeof(rotation) == "number", "")

		rotation = math.clamp(rotation, 0, 3)
		local x = math.clamp(position.X, 0, plot.Grid.X)
		local y = math.clamp(position.Y, 0, plot.Grid.Y)
		position = Vector2.new(x, y)

		local requestResult = requestPlaceObject(plot, id, position, rotation)
		if requestResult.success then
			-- client can place valid item at valid position.
			local baseItemData = ItemData[id]
			local serialized = GridUtil.SerializeCell(baseItemData.Id, position, rotation)
			-- update data
			user:UpdateData("GridObjects", function(gridObjects)
				return Sift.Array.push(gridObjects, serialized)
			end)
			-- update plot
			State:dispatch({
				type = "AddObject",
				key = plot.Key,
				serialized = serialized,
			})
		else
			-- client failed checks. force update
			warn(requestResult.error)
			user:UpdateData("GridObjects", function(gridObjects)
				return gridObjects
			end, true)
		end
	end)
end

return Service
