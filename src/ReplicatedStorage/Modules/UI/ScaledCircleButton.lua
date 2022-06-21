local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)

return function(props)
	local buttonScale = props.buttonScale

	local InputBegan: (inputObject: InputObject) -> () = props.InputBegan
	local InputEnded: (inputObject: InputObject) -> () = props.InputEnded
	local Activated: (inputObject: InputObject) -> () = props.Activated

	return Fusion.New("Frame")({
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 10,

		[Fusion.Children] = {
			Fusion.New("UIScale")({
				Scale = 1.15,
			}),

			Fusion.New("TextButton")({
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),

				[Fusion.OnEvent("Activated")] = function(inputObject: InputObject)
					if Activated then
						Activated(inputObject)
					end
				end,

				[Fusion.OnEvent("InputBegan")] = function(inputObject: InputObject)
					if
						(inputObject.UserInputType == Enum.UserInputType.MouseButton1)
						or (inputObject.UserInputType == Enum.UserInputType.Touch)
					then
						buttonScale:set(0.9)
					elseif inputObject.UserInputType == Enum.UserInputType.MouseMovement then
						buttonScale:set(1.05)
					end

					if InputBegan then
						InputBegan(inputObject)
					end
				end,

				[Fusion.OnEvent("InputEnded")] = function(inputObject: InputObject)
					buttonScale:set(1)
					if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
						buttonScale:set(1)
					end

					if InputEnded then
						InputEnded(inputObject)
					end
				end,

				[Fusion.Children] = {
					Fusion.New("UICorner")({
						CornerRadius = UDim.new(0.5, 0),
					}),
				},
			}),
		},
	})
end
