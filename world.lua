require('entities/vectorentity')

World = {}

local entities = {}

function World.getEntities(type)
	if type then
		local filteredEntities = {}

		for k, entity in ipairs(entities) do
			if class.isInstance(entity, type) then
				table.insert(filteredEntities, entity)
			end
		end

		return table.iterator(filteredEntities)
	end

	return table.iterator(entities)
end

function World.addEntity(entity)
	table.insert(entities, entity)
end

function World.stepEntities()
	local k = 1
	local entity = false

	while k <= #entities do
		entity = entities[k]

		if entity:isRemoved() then
			table.remove(entities, k)
		else
			k = k + 1
		end
	end
end

NetworkState = { None = 1, Host = 2, Client = 3 }

local network_state = NetworkState.None
local sock = nil

function World.getNetworkState()
	return network_state
end

function World.setNetworkState(new_network_state, params)
	network_state = NetworkState.None

	if sock then
		sock:close()
		sock = nil
	end

	if new_network_state ~= NetworkState.None then
		if not params then
			params = {}
		end

		params.address = params.address or '*'
		params.port = params.port or 8888

		local error = 'Invalid Network State!'

		if new_network_state == NetworkState.Host then
			sock, error = socket.bind(params.address, params.port)
		elseif new_network_state == NetworkState.Client then
			sock, error = socket.connect(params.address, params.port)
		end

		if sock then
			network_state = new_network_state
			sock:settimeout(0)
		end

		return sock ~= nil, error
	end

	return true, ''
end

function World.update(delta)
	for entity in World.getEntities() do
		entity:update(delta)
	end

	for ship in World.getEntities(Ship) do
		for entity in World.getEntities() do
			if ship ~= entity then
				if ship:collidesWith(entity) then
					ship:remove()
				end

				if ship:checkForPhotonsCollidingWith(entity) then
					ship:destroyPhotonsCollidingWith(entity)

					if class.isInstance(entity, Ship) and entity.shieldStrength > 200 then
						SoundManager.play(Assets.sounds.shieldhit, {
							pitch = 1 + (-0.2 + (math.random() * 0.4))
						})

						entity.shieldStrength = 0
					else
						entity:remove()
					end
				end
			end
		end
	end

	for ship in World.getEntities(Ship) do
		if ship:isRemoved() and ship.isLocalPlayer then
			World.reset()
		end
	end

	World.stepEntities()
end

local timer = Timer()

function World.draw()
	love.graphics.push('all')
		for entity in World.getEntities() do
			entity:draw()
		end

		local time = timer:getTime() * 3

		if time < 1 then
			love.graphics.setColor((Color.White * (1 - time)):values())
			love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

			local offset = time * (love.graphics.getHeight() / 2)

			love.graphics.setColor(Color.Black:values())

			love.graphics.rectangle('fill', 0, -(love.graphics.getHeight() / 2) - offset, love.graphics.getWidth(), love.graphics.getHeight())
			love.graphics.rectangle('fill', 0, (love.graphics.getHeight() / 2) + offset, love.graphics.getWidth(), love.graphics.getHeight())
		end

		love.graphics.setColor(Color.White:values())
		love.graphics.print("Network State: " .. (table.find(NetworkState, World.getNetworkState()) or "Unknown"), 10, 40)

		if sock then
			love.graphics.print("Network Host: " .. sock:getsockname(), 10, 60)

			if World.getNetworkState() == NetworkState.Client then
				love.graphics.print(("Network Stats: %i in %i out"):format(sock:getstats()), 10, 80)
			end
		end
	love.graphics.pop()
end

function World.reset(exit)
	-- This restarts the really shitty respawn effect
	timer:restart()

	--[[
		Similiar to World.stepEntities() this ensures all entities are iterated upon,
		with as little of a memory and time footprint as possible
	]]
	local k = 1
	local entity = false

	while k <= #entities do
		entity = entities[k]

		if not entity:isRemoved() then
			entity:remove()
		end

		k = k + 1
	end

	entities = {}

	if exit then
		World.setNetworkState(NetworkState.None)
		SoundManager.stopAll('default')

		return
	end

	-- Default spawns

	local dimensions = Vector2(love.graphics.getDimensions()) / 2
	local shipCount = 1
	local angle = math.random() * math.pi * 2
	local angleStep = (math.pi * 2) / shipCount

	for i = 1, shipCount do
		World.addEntity(
			Ship(
				false,
				dimensions + ((dimensions - Vector2.One * 24) * Vector2(math.cos(angle), math.sin(angle))),
				Color.FromHSV(math.random(0, 360), 1, 1)
			)
		)

		angle = angle + angleStep
	end

	World.addEntity(Ship(true, dimensions, Color.White))
end
