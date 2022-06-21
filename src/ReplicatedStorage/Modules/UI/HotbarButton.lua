local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local CircleButton = require(script.Parent.CircleButton)

return function(props)
	local layoutOrder: number = props.LayoutOrder

	local selected = props.selected
	local onSelected = props.onSelected

	local offsetGoal = Fusion.Computed(function()
		return selected:get() and UDim2.fromScale(0.5, 0.3) or UDim2.fromScale(0.5, 0.5)
	end)
	local offsetSpring = Fusion.Spring(offsetGoal, 30, 1)

	local Icon: Frame = props.Icon
	local BorderColor: Color3 = props.BorderColor
	local ButtonColor: Color3 = props.ButtonColor

	return Fusion.New("Frame")({
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		LayoutOrder = layoutOrder,

		[Fusion.Children] = {
			Fusion.New("UIAspectRatioConstraint")({
				AspectRatio = 1,
				AspectType = Enum.AspectType.FitWithinMaxSize,
				DominantAxis = Enum.DominantAxis.Height,
			}),

			CircleButton({
				position = offsetSpring,

				Icon = Icon,
				BorderColor = BorderColor,
				ButtonColor = ButtonColor,

				Activated = function(_inputObject: InputObject)
					onSelected(layoutOrder)
				end,
			}),
		},
	})
end
