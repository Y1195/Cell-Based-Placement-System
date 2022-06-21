local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)

return function(props)
	return Fusion.New("Frame")({
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),

		[Fusion.Children] = {
			Fusion.New("UIScale")({
				Scale = 0.5,
			}),

			Fusion.New("ImageLabel")({
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				Image = props.Image or "rbxasset://textures/ui/GuiImagePlaceholder.png",
				ScaleType = Enum.ScaleType.Fit,
			}),
		},
	})
end
