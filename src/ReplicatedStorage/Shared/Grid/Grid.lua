-- Class
-- 0_1195
-- January 22, 2022

--[[

Grid > Cell > CellObject

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Cell = require(script.Parent.Cell)
local GridUtil = require(script.Parent.GridUtil)

local Class = {}
Class.__index = Class

function Class.new(origin: CFrame, size: Vector2, cellSize: number)
	assert(typeof(origin) == "CFrame", string.format("Argument 1 CFrame expected. Got %s", typeof(origin)))
	assert(typeof(size) == "Vector2", string.format("Argument 2 Vector2 expected. Got %s", typeof(size)))
	assert(typeof(cellSize) == "number", string.format("Argument 3 number expected. Got %s", typeof(cellSize)))

	local width = math.round(size.X / cellSize)
	local length = math.round(size.Y / cellSize)

	local self = setmetatable({
		X = width,
		Y = length,

		cellSize = cellSize,

		gridArray = nil,

		origin = origin,
		size = Vector2.new(width, length),

		CellChanged = Signal.new(),

		_janitor = Janitor.new(),
	}, Class)

	local gridArray = GridUtil.Array2D(width, length)
	for x = 1, self.X do
		for y = 1, self.Y do
			gridArray[x][y] = Cell.new(self, x, y)
		end
	end
	self.gridArray = gridArray

	self._janitor:Add(self.CellChanged)
	self._janitor:Add(function()
		for x = 1, self.X do
			for y = 1, self.Y do
				gridArray[x][y]:Destroy()
			end
			table.clear(gridArray[x])
		end
		self.gridArray = nil
	end)

	return self
end

function Class:__tostring()
	return string.format("Grid<%d, %d>", self.X, self.Y)
end

function Class:_isValid(position: Vector2): boolean
	local width: number = self.X
	local length: number = self.Y
	return (position.X > 0) and (position.Y > 0) and (position.X <= width) and (position.Y <= length)
end

-- function Class:Debug(parent: Instance)
-- 	local gridArray = self.gridArray
-- 	local debugArray = GridUtil.Array2D(self.width, self.length)

-- 	-- local debugPart = GridUtil.CreateDebugPart(parent, self.origin, self.size)
-- 	-- for x = 1, self.width do
-- 	-- 	for y = 1, self.length do
-- 	-- 		debugArray[x][y] = GridUtil.CreateDebugCell(debugPart.SurfaceGui.Frame, gridArray[x][y])
-- 	-- 	end
-- 	-- end

-- 	local octree = Octree.new()
-- 	local previous = {}

-- 	for x = 1, self.width do
-- 		for y = 1, self.length do
-- 			local part = GridUtil.CreateDebugPart(
-- 				parent,
-- 				self:GetWorldCFrame(x, y) * CFrame.new(self.cellSize / 2, 0, self.cellSize / 2),
-- 				gridArray[x][y]
-- 			)
-- 			octree:CreateNode(part.Position, part)
-- 			debugArray[x][y] = part
-- 		end
-- 	end

-- 	local timer = Timer.new(0.1)
-- 	self._janitor:Add(timer)
-- 	timer.Tick:Connect(function()
-- 		for _, part in ipairs(previous) do
-- 			part.SurfaceGui.Enabled = false
-- 		end

-- 		local parts = octree:RadiusSearch(workspace.CurrentCamera.CFrame.Position, 50)
-- 		for _, part in ipairs(parts) do
-- 			part.SurfaceGui.Enabled = true
-- 		end

-- 		previous = parts
-- 	end)
-- 	timer:Start()

-- 	self._debugArray = debugArray

-- 	self._janitor:Add(function()
-- 		table.clear(debugArray)
-- 	end)

-- 	self._janitor:Add(self.CellChanged:Connect(function(x, y, value)
-- 		local text = string.format("[%d,%d]<br />%s", x, y, tostring(value))
-- 		debugArray[x][y].SurfaceGui.Frame.TextLabel.Text = text
-- 	end))
-- end

function Class:GetWorldCFrame(position: Vector2): CFrame
	local origin: CFrame = self.origin
	local cellSize: number = self.cellSize
	local x, y = position.X, position.Y
	x -= 1
	y -= 1
	return origin * CFrame.new(x * cellSize, 0, y * cellSize)
end

function Class:GetXY(cframe: CFrame): Vector2
	local origin: CFrame = self.origin
	local cellSize: number = self.cellSize
	local position = origin:Inverse() * cframe.Position
	local x = math.floor(position.X / cellSize) + 1
	local y = math.floor(position.Z / cellSize) + 1
	return Vector2.new(x, y)
end

function Class:SetCell_XY(position: Vector2, value)
	local gridArray = self.gridArray
	if self:_isValid(position) then
		gridArray[position.X][position.Y] = value
	else
		print(string.format("Tried to place %s at invalid location: [%s]", tostring(value), tostring(position)))
	end
end

function Class:SetCell_CFrame(cframe: CFrame, value)
	local position = self:GetXY(cframe)
	self:SetCell_XY(position, value)
end

function Class:GetCell_XY(position: Vector2)
	local gridArray = self.gridArray
	if self:_isValid(position) then
		return gridArray[position.X][position.Y]
	end
	return nil
end

function Class:GetCell_CFrame(cframe: CFrame)
	local position = self:GetXY(cframe)
	return self:GetCell_XY(position)
end

-- function Class:GetObjects()
-- 	local objects = {}

-- 	for x, row in ipairs(self.gridArray) do
-- 		for y, cellObject in ipairs(row) do
-- 			local placedObject = cellObject:Get()
-- 			if placedObject then
-- 				local objectData = {
-- 					X = x,
-- 					Y = y,
-- 					R = placedObject.Direction,
-- 					Id = placedObject.Id,
-- 				}

-- 				table.insert(objects, objectData)
-- 			end
-- 		end
-- 	end

-- 	return objects
-- end

function Class:Clear()
	local gridArray = self.gridArray
	for x = 1, self.X do
		for y = 1, self.Y do
			local cellObject = gridArray[x][y]
			if cellObject then
				cellObject:Clear()
			end
		end
	end
end

function Class:Destroy()
	self._janitor:Destroy()
end

return Class
