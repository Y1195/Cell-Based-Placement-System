-- Class
-- 0_1195
-- January 10, 2021

--[[



]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Janitor = require(ReplicatedStorage.Packages.Janitor)

local Class = {}
Class.__index = Class

function Class.new(grid, x: number, y: number)
	local self = setmetatable({
		Grid = grid,

		X = x,
		Y = y,

		_janitor = Janitor.new(),
	}, Class)

	return self
end

function Class:__tostring()
	local object = self._janitor:Get("Object")
	return string.format("Cell<%d, %d>%s", self.X, self.Y, tostring(object))
end

function Class:Set(object)
	local oldObject: any = self._janitor:Get("Object")
	if oldObject ~= object then
		if object ~= nil then
			self._janitor:Add(object, nil, "Object")
		else
			self._janitor:Remove("Object")
		end
		self.Grid.CellChanged:Fire(self.X, self.Y, object)
	end
end

function Class:Get()
	return self._janitor:Get("Object")
end

function Class:Clear()
	self:Set(nil)
end

function Class:CanSet()
	return self._janitor:Get("Object") == nil
end

function Class:Destroy()
	self.Grid = nil
	self._janitor:Destroy()
end

return Class
