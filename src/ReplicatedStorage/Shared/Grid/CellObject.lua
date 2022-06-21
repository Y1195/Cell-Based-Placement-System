-- Class
-- 0_1195
-- January 10, 2021

--[[



]]

local Class = {}
Class.__index = Class

function Class.new(value: any, origin: Vector2, direction: number)
	local self = setmetatable({
		Value = value,
		Origin = origin,
		Direction = direction,
	}, Class)

	return self
end

function Class:Get()
	return self.Value
end

function Class:__tostring()
	return string.format("CellObject<%s>", tostring(self.Value))
end

function Class:Destroy()
	local typeOf = typeof(self.Value)
	if typeOf == "Instance" then
		self.Value:Destroy()
	end
	self.Value = nil
end

return Class
