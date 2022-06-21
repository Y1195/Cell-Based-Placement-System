local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UIScale = require(script.Parent.UIScale)

return function(props)
	local AnchorPoint: Vector2 = props.AnchorPoint or Vector2.new(0.5, 0.5)
	local Position: UDim2 = props.Position or UDim2.fromScale(0.5, 0.5)
	local Size: UDim2 = props.Size or UDim2.fromScale(1, 1)

	local BorderColor: Color3 = props.BorderColor or Color3.fromRGB(255, 255, 255)
	local FrameColor: Color3 = props.FrameColor or Color3.fromRGB(0, 0, 0)

	return Fusion.New("Frame")({
		AnchorPoint = AnchorPoint,
		BackgroundTransparency = 1,
		Position = Position,
		Size = Size,

		[Fusion.Children] = {
			UIScale({}),

			Fusion.New("Frame")({
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),

				[Fusion.Children] = {
					Fusion.New("Frame")({ -- container
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = BorderColor,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1),
						ZIndex = 2,

						[Fusion.Children] = {
							Fusion.New("UICorner")({
								CornerRadius = UDim.new(0, 20),
							}),

							Fusion.New("UIPadding")({
								PaddingBottom = UDim.new(0, 5),
								PaddingLeft = UDim.new(0, 5),
								PaddingRight = UDim.new(0, 5),
								PaddingTop = UDim.new(0, 5),
							}),

							Fusion.New("Frame")({ -- frame color
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundColor3 = FrameColor,
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromScale(1, 1),

								[Fusion.Children] = {
									Fusion.New("UICorner")({
										CornerRadius = UDim.new(0, 15),
									}),
								},
							}),

							Fusion.New("Frame")({ -- container
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundTransparency = 1,
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromScale(1, 1),
								ZIndex = 2,

								[Fusion.Children] = {}, -- put content here
							}),
						},
					}),

					Fusion.New("Frame")({ -- shadow
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1),

						[Fusion.Children] = {
							Fusion.New("UIPadding")({
								PaddingBottom = UDim.new(0, -80),
								PaddingLeft = UDim.new(0, -80),
								PaddingRight = UDim.new(0, -80),
								PaddingTop = UDim.new(0, -60),
							}),

							Fusion.New("ImageLabel")({
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundTransparency = 1,
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromScale(1, 1),
								Image = "rbxasset://textures/particles/explosion01_implosion_main.dds",
								ImageColor3 = Color3.fromRGB(0, 0, 0),
								ScaleType = Enum.ScaleType.Slice,
								SliceCenter = Rect.new(128, 128, 128, 128),
							}),
						},
					}),
				},
			}),
		},
	})
end
