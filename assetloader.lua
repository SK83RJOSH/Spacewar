AssetLoader = {}
Assets = {}

local audio = love.audio
local filesystem = love.filesystem
local graphics = love.graphics
local image = love.image

function AssetLoader.loadDirectory(path, basepath)
	local path = string.sub(path, -1) == '/' and path or path .. '/'
	local basepath = basepath or path

	if filesystem.exists(path) and filesystem.isDirectory(path) then
		local files = filesystem.getDirectoryItems(path)

		print("Scanning '" .. path .. "'")

		for k, file in ipairs(files) do
			if filesystem.isDirectory(path .. file) then
				AssetLoader.loadDirectory(path .. file .. '/', basepath)
			else
				local path, filename, extension = string.match(path .. file, "(.-)([^/]-([^/%.]+))$")
				local asset = false

				if table.find({'wav', 'mp3', 'ogg'}, extension) then
					asset = audio.newSource(path .. filename, filesystem.getSize(path .. filename) / 1024 < 1024 and 'static' or 'stream')
				elseif table.find({'bmp', 'tga', 'png', 'jpg', 'dds'}, extension) then
					if extension ~= 'dds' then
						asset = graphics.newImage(path .. filename)
					else
						asset = graphics.newImage(image.newCompressedData(path .. filename))
					end

					asset:setFilter('nearest', 'nearest', 32)

					local filenamejson = string.sub(filename, 1, #filename - #extension) .. 'json'

					if filesystem.exists(path .. filenamejson) then
						local file, err = filesystem.newFile(path .. filenamejson, 'r')

						if not err then
							local json = JSON:decode((file:read()))

							if json.quads then
								local quads = {}

								for name, quad in pairs(json.quads) do
									name = string.gsub(name, "[^%w]", '_')
									quads[name] = graphics.newQuad(quad.x, quad.y, quad.width, quad.height, asset:getWidth(), asset:getHeight())

									print("'" .. name .. "' created from '" .. filenamejson .. "'.")
								end

								asset = SpriteSheet(asset, quads)

								print("'" .. filenamejson .. "' parsed.")
							else
								print("'" .. filenamejson .. "' malformed.")
							end
						else
							print("'" .. filenamejson .. "' could not be parsed.")
						end
					end
				elseif table.find({'ttf', 'otf', 'sfnt', 'fnt'}, extension) then -- Full list of extensions supported available here: http://www.freetype.org/freetype2/docs/
					asset = {
						default = graphics.newFont(path .. filename, 16),
						large = graphics.newFont(path .. filename, 32),
						verylarge = graphics.newFont(path .. filename, 48),
						huge = graphics.newFont(path .. filename, 80),
						gigantic = graphics.newFont(path .. filename, 128),
						path = path .. filename
					}
				elseif table.find({'frag'}, extension) then
					asset = graphics.newShader(path .. filename)
				end

				if asset then
					AssetLoader.put(Assets, string.sub(path, #basepath + 1, #path) .. string.sub(filename, 1, #filename - #extension - 1), asset)
					print("'" .. filename .. "' loaded.")
				elseif extension ~= 'json' then -- Ignore JSON assets, they're complementary to other asset types (like images)
					print("'" .. filename .. "' is not a valid asset.")
				end
			end
		end
	else
		print("'" .. path .. "' is not a directory.")
	end
end

function AssetLoader.put(cache, path, asset)
	local lastCache = false
	local lastPart = false
	local currentCache = cache

	for part in string.gmatch(path, "([^/]+)") do
		part = string.gsub(part, "[^%w]", '_')

		currentCache[part] = currentCache[part] or {}

		lastCache = currentCache
		lastPart = part
		currentCache = currentCache[part]
	end

	lastCache[lastPart] = asset
end

AssetLoader.loadDirectory('assets/fonts', 'assets/')
AssetLoader.loadDirectory('assets/sounds', 'assets/')
AssetLoader.loadDirectory('assets/shaders', 'assets/')
AssetLoader.loadDirectory('assets/images', 'assets/')
