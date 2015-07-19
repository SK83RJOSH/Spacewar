function table.iterator(table)
	local i = 0

	return function()
		i = i + 1

		if i <= #table then
			return table[i]
		end
	end
end

function table.count(table)
	local count = 0

	for k, v in pairs(table) do
		count = count + 1
	end

	return count
end

function table.find(table, value)
	for k, v in pairs(table) do
		if v == value then return k end
	end

	return nil
end

function table.randomvalue(table)
	local rand = math.random(1, table.count(table))
	local count = 1

	for k, v in pairs(table) do
		if rand == count then
			return v
		end
	end
end
