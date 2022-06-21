-- Generic
-- 0_1195
-- January 22, 2022

--[[



]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local ItemData = require(ReplicatedStorage.Game.Shared.ItemData)

local debugPart: Part = Fusion.New("Part")({
	Transparency = 1,
	Size = Vector3.new(4, 1, 4),
	CastShadow = false,
	Anchored = true,
	CanCollide = false,
	CanTouch = false,
	CanQuery = false,
	PivotOffset = CFrame.new(0, 0.5, 0),
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
})

Fusion.New("SurfaceGui")({
	Adornee = debugPart,
	AlwaysOnTop = true,
	Enabled = false,
	Face = Enum.NormalId.Top,
	LightInfluence = 0,
	ResetOnSpawn = false,
	PixelsPerStud = 150,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
	Parent = debugPart,

	[Fusion.Children] = {
		Fusion.New("Frame")({
			BackgroundTransparency = 1,
			Rotation = 90,
			Size = UDim2.fromScale(1, 1),

			[Fusion.Children] = {
				Fusion.New("TextLabel")({
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					RichText = true,
					TextColor3 = Color3.fromRGB(0, 0, 0),
					Font = Enum.Font.GothamBlack,
					Text = "",
					TextSize = 100,
					TextStrokeColor3 = Color3.fromRGB(255, 255, 255),
					TextStrokeTransparency = 0,
					TextWrapped = true,
				}),
			},
		}),
	},
})

local Generic = {}

Generic.Directions = { "Down", "Left", "Up", "Right" }

function Generic.CreateDebugPart(parent: Instance, cframe: CFrame, object: Cell): BasePart
	local text = string.format("[%d,%d]<br />%s", object.x, object.y, tostring(object))
	local part = debugPart:Clone()
	part.SurfaceGui.Frame.TextLabel.Text = text
	part:PivotTo(cframe)
	part.Parent = parent
	return part
end

-- function Generic.CreateDebugPart(parent, cframe, size)
-- 	local part = debugPart:Clone()
-- 	part.Size = Vector3.new(size.X, 1, size.Y)
-- 	part.PivotOffset = CFrame.new(-size.X/2, 0.5, -size.Y/2)
-- 	part:PivotTo(cframe)
-- 	part.Parent = parent
-- 	return part
-- end

-- function Generic.CreateDebugCell(parent, object)
-- 	local label = frame:Clone()
-- 	local text = string.format("[%d,%d]<br />%s", object.x, object.y, tostring(object))
-- 	label.TextLabel.Text = text
-- 	label.Parent = parent
-- 	return label
-- end

function Generic.Array2D(x, y)
	-- return table.create(x, table.create(y)) -- apparently this doesnt work

	local array = table.create(x)
	for i = 1, x do
		table.insert(array, i, table.create(y))
	end
	return array
end

function Generic.GetGridPositionList(id: number, offset: Vector2, dir: string): table
	local gridPositionList = {}
	local baseItemData: ItemData.ItemData = ItemData[id]

	local size = baseItemData.Size
	local width = size.X
	local length = size.Y

	if dir == "Down" or dir == "Up" then
		for x = 0, width - 1 do
			for y = 0, length - 1 do
				table.insert(gridPositionList, offset + Vector2.new(x, y))
			end
		end
	elseif dir == "Left" or dir == "Right" then
		for x = 0, length - 1 do
			for y = 0, width - 1 do
				table.insert(gridPositionList, offset + Vector2.new(x, y))
			end
		end
	end
	return gridPositionList
end

function Generic.GetRotationOffset(id: number, dir: string): Vector2
	local baseItemData: ItemData.ItemData = ItemData[id]

	local size = baseItemData.Size
	local width = size.X
	local length = size.Y

	if dir == "Left" then
		return Vector2.new(0, width)
	elseif dir == "Up" then
		return Vector2.new(width, length)
	elseif dir == "Right" then
		return Vector2.new(length, 0)
	end
	return Vector2.new()
end

function Generic.CanPlaceObjectInGrid(grid, gridPositionList): boolean
	local canSet = true
	for _, gridPosition: Vector2 in gridPositionList do
		local cell = grid:GetCell_XY(gridPosition)
		if not cell or not cell:CanSet() then
			canSet = false
			break
		end
	end
	return canSet
end

function Generic.PlaceObjectInGrid(grid, gridPositionList, cellObject)
	for _, gridPosition: Vector2 in gridPositionList do
		local cell = grid:GetCell_XY(gridPosition)
		if cell then
			cell:Set(cellObject)
		end
	end
end

function Generic.RemoveObjectFromGrid(grid, gridPositionList)
	for _, gridPosition in ipairs(gridPositionList) do
		local cell = grid:GetCell_XY(gridPosition)
		if cell then
			cell:Clear()
		end
	end
end

function Generic.SerializeCell(id: number, position: Vector2, rotation: number): string
	local x, y = position.X, position.Y
	return string.format("%i|%i|%i|%i", id, x, y, rotation)
	-- return {id = id, x = x, y = y, r = rotation}
end

function Generic.DeserializeCell(serialized: string): (number, Vector2, number)
	local id: string, x: string, y: string, rotation: string = string.match(serialized, "(%d+)|(%d+)|(%d+)|(%d+)")
	id = tonumber(id)
	local position = Vector2.new(tonumber(x), tonumber(y))
	rotation = tonumber(rotation)
	return id, position, rotation
	-- local id, x, y, rotation = serialized.id, serialized.x, serialized.y, serialized.r
	-- return id, Vector2.new(x, y), rotation
end

return Generic
