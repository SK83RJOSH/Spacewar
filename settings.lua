Settings = {}

local file = love.filesystem.newFile('settings.msg')
local values = {}

function Settings.load()
	file:open('r')

	if not pcall(function()
		values = MessagePack.unpack(file:read())
	end) then
		values = {}
		Settings.save()
	end

	file:close()
end

function Settings.save()
	file:open('w')
	file:write(MessagePack.pack(values))
	file:close()
end

function Settings.set(key, value)
	values[key] = value
	Settings.save()
end

function Settings.get(key, defaultValue)
	if values[key] == nil then
		Settings.set(key, defaultValue)
	end

	return values[key]
end
