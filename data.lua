-- Data

-- Imports
local lbn = require("lbn")
local table_len = lbn.util.table_len
local table_map = lbn.util.table_map
local table_values = lbn.util.table_values
local array_flatten = lbn.util.array_flatten

-- Get all data modules to add
local data_mods = { "entities", "hotkeys", "items", "recipies", "technologies" }
local data = table_map(data_mods, function(_, mod)
	return mod, require(("data.%s"):format(mod))
end)

-- Log all data we got
do
	for name, table in pairs(data) do
		log(("Found %i %s"):format(table_len(table), name))
	end
end

-- Then flatten it to get all data
local all_data = array_flatten(table_values(data))

-- Then, if not empty, add it all
if #all_data ~= 0 then
	data:extend(all_data)
end
