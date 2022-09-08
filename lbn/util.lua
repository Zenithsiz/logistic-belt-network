---Utilities

local data_util = require("__flib__.data-util")

local util = {}

---Returns if `tbl` is a table
---@param tbl any
---@return boolean
function util.is_table(tbl)
	return type(tbl) == "table"
end

---Asserts `tbl` is a table
---@param tbl any
function util.assert_table(tbl)
	-- Note: Needs to be done like this due to no lazily evaluation
	if not util.is_table(tbl) then
		local msg = ("Expected table, found %s: %s"):format(type(tbl), util.format_value(tbl))
		assert(false, msg)
	end
end

---Returns if `tbl` is an array
---Adapted from `https://stackoverflow.com/questions/7526223`
---@param tbl any
---@return boolean
function util.is_array(tbl)
	-- If it isn't a table, it isn't an array
	if not util.is_table(tbl) then
		return false
	end

	-- Note: We also catch empty arrays
	if #tbl == 0 then
		return next(tbl) == nil
	else
		return next(tbl, #tbl) == nil
	end
end

---Asserts `tbl` is an array
---@param arr any
function util.assert_array(arr)
	-- Note: Needs to be done like this due to no lazily evaluation
	if not util.is_array(arr) then
		local msg = ("Expected array, found %s: %s"):format(type(arr), util.format_value(arr))
		assert(false, msg)
	end
end

---Formats a value
---@param value any
---@return string
function util.format_value(value)
	if util.is_array(value) then
		return util.format_array(value)
	elseif util.is_table(value) then
		return util.format_table(value)
	elseif type(value) == "string" then
		return '"' .. value:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n"):gsub("\t", "\\t") .. '"'
	elseif type(value) == "function" then
		return '"(function)"'
	elseif type(value) == "number" or type(value) == "boolean" or type(value) == "nil" then
		return tostring(value)
	else
		assert(false, ("Unable to format %s: Unknown type"):format(type(value)))
		-- Note: We asserted false, so we won't get to here
		---@diagnostic disable-next-line: missing-return
	end
end

---Formats a table
---@param tbl table
---@return string
function util.format_table(tbl)
	util.assert_table(tbl)

	local s = "{ "

	local cur_idx = 0
	local tbl_len = util.table_len(tbl)
	for key, value in pairs(tbl) do
		s = s .. "[" .. util.format_value(key) .. "]"
		s = s .. " = "
		s = s .. util.format_value(value)

		if cur_idx + 1 == tbl_len then
			break
		end

		s = s .. ", "

		cur_idx = cur_idx + 1
	end

	s = s .. " }"
	return s
end

---Formats an array
---@generic T
---@param arr T[]
---@return string
function util.format_array(arr)
	util.assert_array(arr)

	local s = "{ "

	for idx, value in ipairs(arr) do
		s = s .. util.format_value(value)

		if idx == #arr then
			break
		end

		s = s .. ", "
	end

	s = s .. " }"
	return s
end

---Returns the number of entries in a table
---@param tbl table
---@return integer
function util.table_len(tbl)
	util.assert_table(tbl)

	local count = 0
	for _ in pairs(tbl) do
		count = count + 1
	end
	return count
end

---Maps all keys and values in a table
---@generic K, V, K2, V2
---@param tbl table<K, V>
---@param f fun(key:K, value:V): K2, V2
---@return table<K2, V2>
function util.table_map(tbl, f)
	util.assert_table(tbl)

	local output = {}
	for key, value in pairs(tbl) do
		local key, value = f(key, value)
		output[key] = value
	end
	return output
end

---Maps all values in a table
---@generic K, T, U
---@param tbl table<K, T>
---@param f fun(value: T): U
---@return table<K, U>
function util.table_map_values(tbl, f)
	util.assert_table(tbl)

	return util.table_map(tbl, function(key, value)
		return key, f(value)
	end)
end

---Maps an array
---@generic T, U
---@param tbl T[]
---@param f fun(value: T): U
---@return U[]
function util.array_map(tbl, f)
	util.assert_array(tbl)

	return util.table_map_values(tbl, f)
end

---Maps an array into a table
---@generic T, K, U
---@param tbl T[]
---@param f fun(value: T): K, U
---@return table<K, U>
function util.array_map_table(tbl, f)
	util.assert_array(tbl)

	return util.table_map(tbl, function(_, value)
		local key, value = f(value)
		return key, value
	end)
end

---Returns all values of a table as an array
---@generic K, V
---@param tbl table<K, V>
---@return V[]
function util.table_values(tbl)
	util.assert_table(tbl)

	local output = {}
	for _, value in pairs(tbl) do
		table.insert(output, value)
	end
	return output
end

---Returns all keys of a table as an array
---@generic K, V
---@param tbl table<K, V>
---@return K[]
function util.table_keys(tbl)
	util.assert_table(tbl)

	local output = {}
	for key, _ in pairs(tbl) do
		table.insert(output, key)
	end
	return output
end

---Flattens an array of arrays
---@generic T
---@param arr T[][]
---@return T[]
function util.array_flatten(arr)
	util.assert_array(arr)

	local output = {}
	for _, sub_arr in ipairs(arr) do
		util.assert_array(sub_arr)

		for _, value in ipairs(sub_arr) do
			table.insert(output, value)
		end
	end
	return output
end

return util
