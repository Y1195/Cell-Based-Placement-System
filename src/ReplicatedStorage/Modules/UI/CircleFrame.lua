local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)

return function(props)
	local buttonScale = props.buttonScale

	local Icon: Frame = props.Icon
	local BorderColor: Color3 = props.BorderColor or Color3.fromRGB(255, 255, 255)
	local ButtonColor: Color3 = props.ButtonColor or Color3.fromRGB(0, 0, 0)

	local scaleGoal = Fusion.Computed(function()
		return buttonScale:get()
	end)
	local scaleSpring = Fusion.Spring(scaleGoal, 30, 1)

	return Fusion.New("Frame")({
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),

		[Fusion.Children] = {
			-- tooltip/badge
			Fusion.New("Frame")({
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				ZIndex = 2,

				[Fusion.Children] = {
					-- badge?
					Fusion.New("Frame")({
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.1, 0.1),
						Size = UDim2.fromScale(0.4, 0.4),
						ZIndex = 5,

						[Fusion.Children] = {},
					}),
					-- tooltip?
					Fusion.New("Frame")({
						AnchorPoint = Vector2.new(0.5, 1),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.5, -0.1),
						Size = UDim2.fromScale(1, 0.3),
						ZIndex = 5,

						[Fusion.Children] = {},
					}),
				},
			}),
			-- scale circle
			Fusion.New("Frame")({
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				ZIndex = 1,

				[Fusion.Children] = {
					-- for scaling the frame
					Fusion.New("UIScale")({
						Scale = scaleSpring,
					}),
					-- shadow
					Fusion.New("ImageLabel")({
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.5, 0.7),
						Size = UDim2.fromScale(1, 1),
						Image = "rbxasset://textures/particles/explosion01_implosion_main.dds",
						ImageColor3 = Color3.fromRGB(0, 0, 0),

						[Fusion.Children] = {
							Fusion.New("UIScale")({
								Scale = 2,
							}),
						},
					}),

					Fusion.New("Frame")({
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = BorderColor, -- border color maybe change if selected
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1),
						ZIndex = 2,

						[Fusion.Children] = {
							Fusion.New("UICorner")({
								CornerRadius = UDim.new(0.5, 0),
							}),

							Fusion.New("Frame")({
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundTransparency = 1,
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromScale(1, 1),

								[Fusion.Children] = {
									Fusion.New("UIPadding")({
										PaddingBottom = UDim.new(0, 5),
										PaddingLeft = UDim.new(0, 5),
										PaddingRight = UDim.new(0, 5),
										PaddingTop = UDim.new(0, 5),
									}),

									Fusion.New("Frame")({
										AnchorPoint = Vector2.new(0.5, 0.5),
										BackgroundColor3 = ButtonColor, -- button background color
										Position = UDim2.fromScale(0.5, 0.5),
										Size = UDim2.fromScale(1, 1),

										[Fusion.Children] = {
											Fusion.New("UICorner")({
												CornerRadius = UDim.new(0.5, 0),
											}),
										},
									}),
								},
							}),
							-- icon holder
							Fusion.New("Frame")({
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundTransparency = 1,
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromScale(1, 1),
								ZIndex = 2,

								[Fusion.Children] = {
									Icon,
								},
							}),
						},
					}),
				},
			}),
		},
	})
end
