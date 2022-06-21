local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local ScaledCircleButton = require(script.Parent.ScaledCircleButton)
local CircleFrame = require(script.Parent.CircleFrame)

return function(props)
	local position = props.position

	local InputBegan: (inputObject: InputObject) -> () = props.InputBegan
	local InputEnded: (inputObject: InputObject) -> () = props.InputEnded
	local Activated: (inputObject: InputObject) -> () = props.Activated

	local Icon: Frame = props.Icon
	local BorderColor: Color3 = props.BorderColor
	local ButtonColor: Color3 = props.ButtonColor

	local buttonScale = Fusion.State(1)

	return Fusion.New("Frame")({
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = position, -- for positioning the button
		Size = UDim2.fromScale(1, 1),

		[Fusion.Children] = {
			CircleFrame({
				buttonScale = buttonScale,

				Icon = Icon,
				BorderColor = BorderColor,
				ButtonColor = ButtonColor,
			}),

			ScaledCircleButton({
				buttonScale = buttonScale,

				Activated = Activated,
				InputBegan = InputBegan,
				InputEnded = InputEnded,
			}),
		},
	})
end
