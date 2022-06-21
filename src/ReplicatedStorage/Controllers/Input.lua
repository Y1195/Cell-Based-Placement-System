-- InputController
-- 0_1195
-- May 09, 2022

--[[



]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInput = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Input = require(ReplicatedStorage.Packages.Input)
local State = require(ReplicatedStorage.Game.Modules.State)
local DataDefaults = require(ReplicatedStorage.Game.Shared.DataDefaults)
local Sift = require(ReplicatedStorage.Packages.sift)
local RoduxWatcher = require(ReplicatedStorage.Game.Shared.RoduxWatcher)

local PreferredInput = Input.PreferredInput

local keybinds = Sift.Dictionary.copyDeep(DataDefaults.Keybinds)

local actions = {}

local watcher = RoduxWatcher(State)

local Controller = Knit.CreateController({
	Name = "InputController",
})

local function updateKeybinds(newKeybinds)
	local preferredInput = Controller:GetPreferredInput()
	for _, action in actions do
		-- print(action.name)
		action.keybind = newKeybinds[preferredInput][action.name] or keybinds[preferredInput][action.name]
	end
end

function Controller:Add(actionName: string, callback: () -> ())
	if actions[actionName] then
		warn(string.format("%s action already added", actionName))
		return nil
	end

	local keybind = self:GetKeyFromAction(actionName)

	local action = {
		name = actionName,
		callback = callback,
		enabled = true,
		keybind = keybind,
	}

	actions[actionName] = action

	return action
end

function Controller:SetEnabled(actionName: string, enabled: boolean)
	local action = actions[actionName]
	if not action then
		warn(string.format("%s action does not exist", actionName))
		return
	end

	action.enabled = enabled
end

function Controller:GetPreferredInput(): string
	return State:getState().input.preferredInput
end

function Controller:GetKeyFromAction(actionName: string): string?
	local preferredInput = self:GetPreferredInput()
	return keybinds[preferredInput][actionName]
end

local camera = workspace.CurrentCamera
local Mouse = Input.Mouse

local params = RaycastParams.new()
params.IgnoreWater = true
function Controller:CastInWorld(distance: number, ignore: { Instance })
	local overridePos: Vector2

	local preferredInput = self:GetPreferredInput()
	if preferredInput ~= "Keyboard" then
		overridePos = camera.ViewportSize / 2
	end
	local viewportMouseRay = Mouse:GetRay(overridePos)
	local origin = viewportMouseRay.Origin
	local direction = viewportMouseRay.Direction * distance
	params.FilterDescendantsInstances = ignore
	local raycastResult = workspace:Raycast(origin, direction, params)
	return { raycastResult = raycastResult, Origin = origin, Direction = direction }
end

function Controller:KnitStart() end

function Controller:KnitInit()
	local preferredMap = {
		["MouseKeyboard"] = "Keyboard",
		["Gamepad"] = "Gamepad",
		["Touch"] = "Touch",
	}
	PreferredInput.Observe(function(preferred)
		local preferredName = preferredMap[preferred.Name]
		State:dispatch({
			type = "SetPreferred",
			preferredInput = preferredName,
		})
	end)
	-- watch for keybinds changed
	watcher(function(state)
		return state.data.Keybinds
	end, function(newKeybinds)
		updateKeybinds(newKeybinds)
	end)

	local function inputBegan(inputObject: InputObject, gameProcessedEvent: boolean)
		if gameProcessedEvent then
			return
		end

		local key = inputObject.KeyCode.Name
		local inputType = inputObject.UserInputType

		if string.match(inputType.Name, "^Mouse") then
			key = inputType.Name
		elseif inputType == Enum.UserInputType.Touch then
			key = "Touch"
		end

		if key == "Unknown" then
			return
		end

		-- different actions can have the same key
		local actionsToRun = {}
		for _, action in actions do
			if (action.keybind == key) and action.enabled then
				table.insert(actionsToRun, action)
			end
		end

		for _, action in actionsToRun do
			if not (action and typeof(action.callback) == "function") then
				continue
			end
			action.callback(action.name, inputObject.UserInputState, inputObject)
		end

		-- print(key)
	end

	--[[
	https://devforum.roblox.com/t/inputbegan-doesnt-work-for-io-but-inputended-does/1509584
	local ContextAction = game:GetService("ContextActionService")
	ContextAction:BindActionAtPriority("INPUT", function(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)
		if inputState == Enum.UserInputState.Begin then
			local key = inputObject.KeyCode.Name
			local inputType = inputObject.UserInputType
			print(key)
			if string.match(inputType.Name, "^Mouse") then
				key = inputType.Name
			elseif inputType == Enum.UserInputType.Touch then
				key = "Touch"
			end

			if key == "Unknown" then
				return Enum.ContextActionResult.Pass
			end

		end
		return Enum.ContextActionResult.Pass
	end, false, 10000, unpack(Enum.KeyCode:GetEnumItems()))
]]

	UserInput.InputBegan:Connect(inputBegan)
end

return Controller
