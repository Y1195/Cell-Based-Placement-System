local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UIScale = require(script.Parent.UIScale)
local HotbarButton = require(script.Parent.HotbarButton)
-- local ImageFrame = require(script.Parent.ImageFrame)
local Viewport = require(script.Parent.Viewport)
local ItemData = require(ReplicatedStorage.Game.Shared.ItemData)

return function(props)
	local hotbarItems = props.hotbarItems
	local selectedSlot = props.selectedSlot
	local onSelected: (index: number) -> () = props.onSelected

	return Fusion.New("Frame")({
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 1, -20),
		Size = UDim2.new(1, 0, 0, 100),

		[Fusion.Children] = {
			Fusion.New("UIListLayout")({
				Padding = UDim.new(0, 20),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			UIScale({}),

			Fusion.ComputedPairs(hotbarItems, function(index: number, id: number)
				local baseItemData = ItemData[id]

				local Current = Fusion.State()
				local prefab = baseItemData.Prefab
				if prefab then
					prefab = prefab:Clone()
					Current:set(prefab)
				end

				local Icon: ViewportFrame = Viewport({
					Current = Current,
					Fov = Fusion.State(20),
				})

				return HotbarButton({
					LayoutOrder = index,
					selected = Fusion.Computed(function()
						return index == selectedSlot:get()
					end),
					onSelected = onSelected,

					Icon = Icon,
					ButtonColor = Color3.fromRGB(151, 184, 255),
				})
			end),
		},
	})
end
