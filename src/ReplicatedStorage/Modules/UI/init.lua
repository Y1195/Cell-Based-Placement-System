local ScreenGui = require(script.ScreenGui)

return {
	Back = ScreenGui({
		DisplayOrder = 1,
	}),

	Gui = ScreenGui({
		DisplayOrder = 5,
	}),

	Front = ScreenGui({
		DisplayOrder = 10,
	}),

	ScreenGui = ScreenGui,
	UIScale = require(script.UIScale),
	Hotbar = require(script.Hotbar),
	ScaledCircleButton = require(script.ScaledCircleButton),
	HotbarButton = require(script.HotbarButton),
	CircleFrame = require(script.CircleFrame),
	CircleFrameIcon = require(script.CircleFrameIcon),
	CircleButton = require(script.CircleButton),
	ImageFrame = require(script.ImageFrame),
	ScaledFrame = require(script.ScaledFrame),
	Viewport = require(script.Viewport),
}
