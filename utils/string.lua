function string.split(string, delimiter)
	result = {}

	for match in (string .. delimiter):gmatch("(.-)" .. delimiter) do
		table.insert(result, match)
	end

	return unpack(result)
end
