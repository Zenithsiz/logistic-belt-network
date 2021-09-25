-- Utilities

local util = {}

-- Returns if `tbl` is a table
function util.is_table(tbl)
	return type(tbl) == "table"
end

-- Asserts `tbl` is a table
function util.assert_table(tbl)
	-- Note: Needs to be done like this due to no lazily evaluation
	if not util.is_table(tbl) then
		local msg = ("Expected table, found %s: %s"):format(type(tbl), util.format_value(tbl))
		assert(false, msg)
	end
end

-- Returns if `tbl` is an array
-- Adapted from `https://stackoverflow.com/questions/7526223`
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

-- Asserts `tbl` is an array
function util.assert_array(arr)
	-- Note: Needs to be done like this due to no lazily evaluation
	if not util.is_array(arr) then
		local msg = ("Expected array, found %s: %s"):format(type(arr), util.format_value(arr))
		assert(false, msg)
	end
end

-- Formats a value
function util.format_value(value)
	if util.is_array(value) then
		return util.format_array(value)
	elseif util.is_table(value) then
		return util.format_table(value)
	elseif type(value) == "string" then
		return ('"%s"'):format(tostring(value))
	else
		return tostring(value)
	end
end

-- Formats a table
function util.format_table(tbl)
	util.assert_table(tbl)

	local s = "{ "

	local cur_idx = 0
	local tbl_len = util.table_len(tbl)
	for key, value in pairs(tbl) do
		s = s .. util.format_value(key)
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

-- Formats an array
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

-- Returns the number of entries in a table
function util.table_len(tbl)
	util.assert_table(tbl)

	local count = 0
	for _ in pairs(tbl) do
		count = count + 1
	end
	return count
end

-- Maps all keys and values in a table
function util.table_map(tbl, f)
	util.assert_table(tbl)

	local output = {}
	for key, value in pairs(tbl) do
		key, value = f(key, value)
		output[key] = value
	end
	return output
end

-- Maps all values in a table
function util.table_map_values(tbl, f)
	util.assert_table(tbl)

	return util.table_map(tbl, function(key, value)
		return key, f(value)
	end)
end

-- Returns all values of a table as an array
function util.table_values(tbl)
	util.assert_table(tbl)

	local output = {}
	for _, value in pairs(tbl) do
		table.insert(output, value)
	end
	return output
end

-- Flattens an array of arrays
function util.array_flatten(arr)
	util.assert_array(arr)

	local output = {}
	for _, sub_arr in ipairs(arr) do
		assert(util.is_array(sub_arr))

		for _, value in ipairs(sub_arr) do
			table.insert(output, value)
		end
	end
	return output
end

return util
