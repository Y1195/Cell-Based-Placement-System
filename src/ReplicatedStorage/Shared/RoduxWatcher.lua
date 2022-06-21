--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rodux = require(ReplicatedStorage.Game.Rodux)

return function(store: Rodux.Store)
	return function<T>(selector: (any) -> (T), onChange: (any) -> ()): () -> ()
		local value = selector(store:getState())

		local connection = store.changed:connect(function(newState, _oldState)
			local newValue = selector(newState)
			if newValue == value then
				return
			end
			value = newValue
			onChange(value)
		end)

		onChange(value)

		return connection.disconnect
	end
end
