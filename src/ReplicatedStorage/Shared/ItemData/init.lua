local ReplicatedStorage = game:GetService("ReplicatedStorage")
export type ItemData = {
	Id: number,
	Name: string,

	Type: "Placeable" | "Tool",

	Size: Vector2,

	ToolType: "Delete" | string,

	Module: ModuleScript,
	Prefab: Model?,
}

local itemData: {[number]: ItemData} = {}

local function initPrefab(baseItemData: ItemData): Model?
	local prefab: Model? = ReplicatedStorage.Assets:FindFirstChild(baseItemData.Name)
	if prefab then
		-- TODO setup model?
		prefab:SetAttribute("Id", baseItemData.Id)
		return prefab
	else
		return
	end
end

for _, module: ModuleScript in script:GetChildren() do
	local baseItemData: ItemData = require(module)
	baseItemData.Module = module

	local prefab = initPrefab(baseItemData)
	baseItemData.Prefab = prefab

	if itemData[baseItemData.Id] then
		warn(string.format("Conflicting Ids: %d %s %s", baseItemData.Id, baseItemData.Name, itemData[baseItemData.Id].Name))
	end

	itemData[baseItemData.Id] = baseItemData
end

return itemData