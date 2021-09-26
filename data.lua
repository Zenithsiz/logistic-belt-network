-- Data

-- Imports
local lbn = require("lbn")

-- Get all data modules to add
local data_mods = { "entities", "hotkeys", "items", "recipies", "technologies" }
local data_to_add = lbn.util.array_map_table(data_mods, function(mod)
	return mod, require(("data.%s"):format(mod))
end)

-- Then add them all
do
	for name, arr in pairs(data_to_add) do
		lbn.util.assert_array(arr)

		if settings.startup["lbn:log"].value then
			log(("Adding %i %s: %s"):format(#arr, name, lbn.util.format_array(arr)))
		end

		if #arr ~= 0 then
			data:extend(arr)
		end
	end
end
