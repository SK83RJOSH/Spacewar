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
local clientID = nil
local clients = {}
local updateTimer = Timer()
local clientTimer = Timer()

function World.getNetworkState()
	return network_state
end

function World.setNetworkState(new_network_state, params)
	network_state = NetworkState.None

	if sock then
		for k, client in ipairs(clients) do
			client.sock:close()
		end

		sock:close()
		sock = nil
	end

	clientID = nil
	clients = {}
	updateTimer:restart()
	clientTimer:restart()

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
			sock:setoption('keepalive', true)
			sock:setoption('tcp-nodelay', true)
		end

		return sock ~= nil, error
	end

	return true, ''
end

function World.sendNetworkMessage(message, data, targetSock)
	if World.getNetworkState() ~= NetworkState.None then
		local data = MessagePack.pack({
			message, data
		})
		local message = #data .. "\n" .. data

		if targetSock then
			targetSock:send(message)
		else
			if World.getNetworkState() == NetworkState.Host then
				for k, client in ipairs(clients) do
					client.sock:send(message)
				end
			else
				sock:send(message)
			end
		end
	end
end

function World.readNetworkMessage(targetSock)
	targetSock = targetSock or sock

	if World.getNetworkState() ~= NetworkState.None then
		local bytes, error = targetSock:receive()

		if tonumber(bytes) then
			local data, error, partial = targetSock:receive(bytes)

			if data then
				local success, data = pcall(function()
					return MessagePack.unpack(data)
				end)

				if success then
					return data, nil
				end

				print("Failed to unpack!")

				return false, nil
			end

			print("Failed to receive bytes (reported message length was " .. bytes .. " bytes; read " .. #partial .. " bytes)")

			if #partial > 0 then
				print("Partial was: " .. partial)
			end

			return false, error
		end

		return false, error
	end

	return false, nil
end

function World.pumpNetworkQueue()
	local updateReceived = false

	if World.getNetworkState() == NetworkState.Host then
		local client, error = sock:accept()

		if client then
			local clientID = os.time() .. '_' .. math.random(9999)

			client:settimeout(0)
			client:setoption('keepalive', true)
			client:setoption('tcp-nodelay', true)

			World.sendNetworkMessage("ClientID", {clientID}, client)

			World.addEntity(Ship(clientID, Vector2(math.random(love.graphics.getWidth()), math.random(love.graphics.getHeight())), Color.fromHSV(1, 1, math.random(360))))

			for entity in World.getEntities() do
				World.sendNetworkMessage("EntityCreate", {
					entity.class.name,
					entity.__instance,
					entity:buildNetworkConstructor()
				}, client)
			end

			table.insert(clients, {
				sock = client,
				id = clientID,
				timer = Timer(),
				ping = -1
			})

			print("Server: Client " .. client:getpeername() .. " (" .. clientID .. ") added")

			updateReceived = true
		end

		for k = 1, #clients do
			local client = clients[k]

			if client then
				local data, error = World.readNetworkMessage(client.sock)

				if data then
					local event, data = unpack(data)

					if event == "Pong" then
						client.ping = math.round(client.timer:getTime() * 1000)
						client.timer:restart()
					elseif event == "ShipUpdate" then
						for ship in World.getEntities(Ship) do
							if ship.isLocalPlayer == client.id then
								-- local position, velocity, rotation = ship.position:copy(), ship.velocity:copy(), ship.rotation

								ship:applyNetworkUpdate(data)

								-- if ship.position:distance(position) > 4 then
								-- 	ship.position = position
								-- end
								--
								-- if math.abs(ship.velocity:length() - velocity:length()) > Ship.MAXIMUM_SHIP_THRUST / 32 then
								-- 	ship.velocity = velocity
								-- end
								--
								-- if math.abs(ship.rotation - rotation) > math.pi / 2 / 32 then
								-- 	ship.rotation = rotation
								-- end
							end
						end
					end
				elseif error == 'closed' or client.timer:getTime() > 10 then
					print("Server: Client " .. client.sock:getpeername() .. " (" .. client.id .. ") removed (" .. (error == 'closed' and 'Connection closed' or 'Timeout') .. ")")

					client.sock:close()

					for ship in World.getEntities(Ship) do
						if ship.isLocalPlayer == client.id then
							ship:remove()
						end
					end

					table.remove(clients, k)

					k = k - 1
				end

				if error ~= 'timeout' then
					updateReceived = true
				end
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

		if clientTimer:getTime() > 5 then
			for k, client in ipairs(clients) do
				if client.timer:getTime() < 5 then
					client.timer:restart()
				end
			end

			World.sendNetworkMessage("Ping")
			clientTimer:restart()
		end
	elseif World.getNetworkState() == NetworkState.Client then
		local data, error = World.readNetworkMessage()

		if data then
			local event, data = unpack(data)

			if event == "Ping" then
				World.sendNetworkMessage("Pong")
				clientTimer:restart()
			elseif event == "ClientID" then
				clientID = unpack(data)
			elseif event == "EntityCreate" then
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
						-- if class.isInstance(entity, Ship) and entity.isLocalPlayer == World.getClientID() then
						-- 	local position, velocity, rotation = entity.position:copy(), entity.velocity:copy(), entity.rotation
						-- 	local vkLeft, vkRight, vkForward, vkReverse, vkFire = entity.vkLeft, entity.vkRight, entity.vkForward, entity.vkReverse, entity.vkForward, entity.vkFire
						--
						-- 	entity:applyNetworkUpdate(update)
						--
						-- 	entity.position = math.lerp(entity.position, position, 0.75)
						-- 	entity.velocity = math.lerp(entity.velocity, velocity, 0.75)
						-- 	entity.rotation = math.lerp(entity.rotation, rotation, 0.75)
						--
						-- 	entity.vkLeft = vkLeft
						-- 	entity.vkRight = vkRight
						-- 	entity.vkForward = vkForward
						-- 	entity.vkReverse = vkReverse
						-- 	entity.vkReverse = vkReverse
						-- else
						if not class.isInstance(entity, Ship) or entity.isLocalPlayer ~= World.getClientID() then
							entity:applyNetworkUpdate(update)
						end
						-- end
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
		elseif error == 'closed' or clientTimer:getTime() > 10 then
			setGameState(GameState.Menu)
			GUI.pushMenu(ErrorMenu(error == 'closed' and "Connection Closed!" or "Connection Timeout!"))
		end

		if updateTimer:getTime() > 1 / 32 then
			for ship in World.getEntities(Ship) do
				if ship.isLocalPlayer == World.getClientID() then
					World.sendNetworkMessage("ShipUpdate", ship:buildNetworkUpdate())
				end
			end

			updateTimer:restart()
		end

		updateReceived = error ~= 'timeout'
	end

	if updateReceived then
		World.pumpNetworkQueue()
	end
end

function World.getClientID()
	return clientID
end

function World.update(delta)
	if World.getNetworkState() ~= NetworkState.None then
		World.pumpNetworkQueue()
	end

	local shipCount = 0

	for ship in World.getEntities(Ship) do
		if World.getNetworkState() == NetworkState.Client then
			if ship:isRemoved() and ship.isLocalPlayer == true then
				World.reset()
			end
		end

		if not ship:isRemoved() then
			shipCount = shipCount + 1
		end
	end

	if shipCount <= 1 and #clients > 0 then
		World.reset()
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
					love.graphics.print((client.sock:getpeername() .. " Stats: %i in %i out " .. client.ping .. "ms Ping"):format(client.sock:getstats()), 10, 40 + (20 * k))
				end
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
			-- 		Color.fromHSV(math.random(0, 360), 1, 1)
			-- 	)
			-- )

			angle = angle + angleStep
		end

		World.addEntity(Ship(true, dimensions, Color.White))

		for k, client in ipairs(clients) do
			World.addEntity(Ship(client.id, Vector2(math.random(love.graphics.getWidth()), math.random(love.graphics.getHeight())), Color.fromHSV(1, 1, math.random(360))))
		end
	end
end
