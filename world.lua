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
	if World.getNetworkState() == NetworkState.Host then
		print("Server: Creating entity " .. entity.class.name)

		World.sendNetworkMessage("EntityCreate", {
			entity.class.name,
			entity.__instance,
			entity:buildNetworkConstructor()
		})
	end

	table.insert(entities, entity)
end

function World.stepEntities()
	local k = 1
	local entity = false

	while k <= #entities do
		entity = entities[k]

		if entity:isRemoved() then
			if World.getNetworkState() == NetworkState.Host then
				print("Server: Removing entity " .. entity.class.name)

				World.sendNetworkMessage("EntityRemove", {
					entity.__instance
				})
			end

			table.remove(entities, k)
		else
			k = k + 1
		end
	end
end

NetworkState = { None = 1, Host = 2, Client = 3 }

local network_state = NetworkState.None
local sock = nil
local clients = {}
local updateTimer = Timer()

function World.getNetworkState()
	return network_state
end

function World.setNetworkState(new_network_state, params)
	network_state = NetworkState.None

	if sock then
		sock:close()
		sock = nil

		for k, client in ipairs(clients) do
			client:close()
		end

		clients = {}
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

function World.sendNetworkMessage(message, data, client)
	local data = MessagePack.pack({
		message, data
	})

	if client then
		client:send(#data .. "\n" .. data)
	else
		for k, client in ipairs(clients) do
			client:send(#data .. "\n" .. data)
		end
	end
end

function World.processNetworkQueue()
	local updateReceived = false

	if World.getNetworkState() == NetworkState.Host then
		local client, error = sock:accept()

		if client then
			print("Server: Client " .. client:getpeername() .. " added")
			client:settimeout(0)

			for entity in World.getEntities() do
				World.sendNetworkMessage("EntityCreate", {
					entity.class.name,
					entity.__instance,
					entity:buildNetworkConstructor()
				}, client)
			end

			table.insert(clients, client)
			updateReceived = true
		end

		for k = 1, #clients do
			local client = clients[k]
			local data, error = client:receive()

			if data then
				print("Server: " .. data .. " that's some great soup!")
			elseif error == 'closed' then
				print("Server: Client " .. client:getpeername() .. " removed")

				table.remove(clients, k)
				k = k - 1
			end

			if error ~= 'timeout' then
				updateReceived = true
			end
		end

		if updateTimer:getTime() > 1 / 32 then
			for entity in World.getEntities() do
				World.sendNetworkMessage("EntityUpdate", {
					entity.__instance,
					entity:buildNetworkUpdate()
				})
			end

			updateTimer:restart()
		end
	elseif World.getNetworkState() == NetworkState.Client then
		local data, error = sock:receive()

		if data then
			local event, data = unpack(MessagePack.unpack(sock:receive(data)))

			if event == "EntityCreate" then
				local class_instance, instance, constructor = unpack(data)

				if _G[class_instance] and class.isClass(_G[class_instance]) and _G[class_instance]:extends(SpaceWarEntity) then
					for k, v in ipairs(constructor) do
						if type(v) == 'table' then
							if #v == 2 then
								constructor[k] = Vector2(unpack(v))
							elseif #v == 4 then
								constructor[k] = Color(unpack(v))
							end
						end
					end

					local entity = _G[class_instance](unpack(constructor))

					entity.__instance = instance

					World.addEntity(entity)

					print("Client: Creating entity " .. entity.class.name)
				else
					print("Client: Attempted to create instance of non-existent entity '" .. class_instance .. "'")
				end
			elseif event == "EntityUpdate" then
				local instance, update = unpack(data)

				for entity in World.getEntities() do
					if entity.__instance == instance then
						entity:applyNetworkUpdate(update)
					end
				end
			elseif event == "EntityRemove" then
				local instance = unpack(data)

				for entity in World.getEntities() do
					if entity.__instance == instance then
						entity:remove()
						print("Client: Removing entity " .. entity.class.name)
					end
				end
			end
		elseif error == 'closed' then
			GUI.pushMenu(ErrorMenu("Connection Lost!"))
			setGameState(GameState.Menu)
		end

		updateReceived = error ~= 'timeout'
	end

	return updateReceived
end

function World.update(delta)
	while World.getNetworkState() ~= NetworkState.None and World.processNetworkQueue() do end

	for ship in World.getEntities(Ship) do
		if ship:isRemoved() and ship.isLocalPlayer == true then
			World.reset()
		end
	end

	World.stepEntities()

	for entity in World.getEntities() do
		entity:update(delta)
	end

	for ship in World.getEntities(Ship) do
		for entity in World.getEntities() do
			if ship ~= entity then
				if ship:collidesWith(entity) and World.getNetworkState() ~= NetworkState.Client then
					ship:remove()
				end

				if ship:checkForPhotonsCollidingWith(entity) then
					ship:destroyPhotonsCollidingWith(entity)

					if class.isInstance(entity, Ship) and entity.shieldStrength > 200 then
						SoundManager.play(Assets.sounds.shieldhit, {
							pitch = 1 + (-0.2 + (math.random() * 0.4))
						})

						entity.shieldStrength = 0
					elseif World.getNetworkState() ~= NetworkState.Client and not class.isInstance(entity, Sun) then
						entity:remove()
					end
				end
			end
		end
	end
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
			if World.getNetworkState() == NetworkState.Client then
				love.graphics.print("Network Host: " .. sock:getsockname(), 10, 60)
				love.graphics.print(("Network Stats: %i in %i out"):format(sock:getstats()), 10, 80)
			else
				for k, client in ipairs(clients) do
					love.graphics.print((client:getpeername() .. " Stats: %i in %i out"):format(client:getstats()), 10, 40 + (20 * k))
				end
			end
		end
	love.graphics.pop()
end

function World.reset(exit)
	print(exit and "exiting" or "resetting")

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

	World.stepEntities()

	if exit then
		World.setNetworkState(NetworkState.None)
		SoundManager.stopAll('sfx')

		return
	end

	-- Default spawns

	if World.getNetworkState() ~= NetworkState.Client then
		local dimensions = Vector2(love.graphics.getDimensions()) / 2
		local shipCount = 1
		local angle = math.random() * math.pi * 2
		local angleStep = (math.pi * 2) / shipCount

		for i = 1, shipCount do
			-- World.addEntity(
			-- 	Ship(
			-- 		false,
			-- 		dimensions + ((dimensions - Vector2.One * 24) * Vector2(math.cos(angle), math.sin(angle))),
			-- 		Color.FromHSV(math.random(0, 360), 1, 1)
			-- 	)
			-- )

			angle = angle + angleStep
		end

		World.addEntity(Ship(true, dimensions, Color.White))
	end
end
