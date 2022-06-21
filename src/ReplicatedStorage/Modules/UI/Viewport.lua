local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)

-- https://github.com/Quenty/NevermoreEngine/blob/main/src/viewport/src/Shared/Viewport.lua

local function fitSphereToCamera(radius, fovDeg, aspectRatio)
	local halfFov = 0.5 * math.rad(fovDeg)
	if aspectRatio < 1 then
		halfFov = math.atan(aspectRatio * math.tan(halfFov))
	end

	return radius / math.sin(halfFov)
end

local function getCubeoidDiameter(size)
	return math.sqrt(size.x ^ 2 + size.y ^ 2 + size.z ^ 2)
end

local function fitBoundingBoxToCamera(size, fovDeg, aspectRatio)
	local radius = getCubeoidDiameter(size) / 2
	return fitSphereToCamera(radius, fovDeg, aspectRatio)
end

return function(props)
	local current = props.Current or Fusion.State()
	local fov = props.Fov or Fusion.State(20)

	local absoluteSize = Fusion.State(Vector2.new())
	local rotationYaw = Fusion.State(math.pi / 4)
	-- local rotationYawSpring = Spring(rotationYaw)
	local rotationPitch = Fusion.State(-math.pi / 6)
	-- local rotationPitchSpring = Spring(rotationPitch)

	local camera = Fusion.New("Camera")({
		FieldOfView = fov,
		CFrame = Fusion.Computed(function()
			if not current:get() then
				return CFrame.new()
			end

			local aspectRatio = absoluteSize:get().X / absoluteSize:get().Y
			local bbCFrame, bbSize = current:get():GetBoundingBox()
			if not bbCFrame then
				return CFrame.new()
			end

			local fit = fitBoundingBoxToCamera(bbSize, fov:get(), aspectRatio)
			return CFrame.new(bbCFrame.p)
				* CFrame.Angles(0, rotationYaw:get(), 0)
				* CFrame.Angles(rotationPitch:get(), 0, 0)
				* CFrame.new(0, 0, fit)
		end),
	})

	return Fusion.New("ViewportFrame")({
		LightColor = Color3.fromRGB(255, 255, 255),
		Ambient = Color3.fromRGB(255, 255, 255),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromRGB(95, 95, 95),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		CurrentCamera = camera,

		[Fusion.OnChange("AbsoluteSize")] = function(size)
			absoluteSize:set(size)
		end,

		[Fusion.Children] = {
			current,
			camera,
		},
	})
end
