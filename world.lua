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
	if Network.getState() == NetworkState.Server then
		print("Server: Creating entity " .. entity.class.name)

		Network.broadcast("EntityCreate", {
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
			if Network.getState() == NetworkState.Server then
				print("Server: Removing entity " .. entity.class.name)

				Network.broadcast("EntityRemove", {
					entity.__instance,
				})
			end

			table.remove(entities, k)
		else
			k = k + 1
		end
	end
end

local timer = Timer()
local updateTimer = Timer()

function World.update(delta)
	if Network.getState() ~= Network.None then
		if Network.getState() == NetworkState.Server then
			if updateTimer:getTime() > 1 / Network.TickRate then
				for entity in World.getEntities() do
					Network.broadcast("EntityUpdate", {
						entity.__instance,
						entity:buildNetworkUpdate()
					}, 0, 'unreliable')
				end

				updateTimer:restart()
			end
		end

		for event in Network.getEvents() do
			if event.type == "connect" then
				if Network.getState() == NetworkState.Server then
					print("Server: Adding client (" .. event.peer:connect_id() .. ")")

					for entity in World.getEntities(entity) do
						Network.send("EntityCreate", {
							entity.class.name,
							entity.__instance,
							entity:buildNetworkConstructor()
						}, event.peer)
					end

					for id, username in Network.getUsernames() do
						Network.send("SetUsername", {
							id,
							username
						}, event.peer)
					end

					World.addEntity(Ship(event.peer:connect_id(), Vector2(math.random(love.graphics.getWidth()), math.random(love.graphics.getHeight())), Color.fromHSV(1, 1, math.random(360))))
				else
					Network.send("SetUsername", Settings.get('network_username') or Network.DefaultUsername)
				end
			elseif event.type == "disconnect" then
				if Network.getState() == NetworkState.Client then
					Network.close()

					GUI.pushMenu(ErrorMenu("Connection Closed!"))
					setGameState(GameState.Menu)
				else
					print("Server: Server removing client (" .. event.peer:connect_id() .. ")")
				end
			elseif event.type == "receive" then
				local peer = event.peer
				local event, data = unpack(MessagePack.unpack(event.data))

				if Network.getState() == NetworkState.Server then
					if event == "SetUsername" then
						Network.setUsername(peer:connect_id(), data)
					elseif event == "InputChanged" then
						local input, value = unpack(data)

						for ship in World.getEntities(Ship) do
							if ship.peerID == peer:connect_id() then
								if input == 'w' then
									ship.vkForward = value
								elseif input == 's' then
									ship.vkReverse = value
								elseif input == 'a' then
									ship.vkLeft = value
								elseif input == 'd' then
									ship.vkRight = value
								elseif input == 'space' then
									ship.vkFire = value
								end
							end
						end
					end
				else
					if event == "SetUsername" then
						Network.setUsername(unpack(data))
					elseif event == "EntityCreate" then
						local class_instance, instance, constructor = unpack(data)

						if _G[class_instance] and class.isClass(_G[class_instance]) and _G[class_instance]:extends(SpaceWarEntity) then
							for k, v in ipairs(constructor) do
								print(type(v))

								if type(v) == 'table' then
									print(#v)

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
					elseif event == "Reset" then
						World.reset()
					end
				end

			end
		end
	end

	local shipCount = 0

	for ship in World.getEntities(Ship) do
		if Network.getState() == NetworkState.None then
			if ship:isRemoved() and ship:isLocalPlayer() then
				World.reset()
			end
		end

		if not ship:isRemoved() then
			shipCount = shipCount + 1
		end
	end

	if shipCount <= 1 and Network.getPeerCount() >= 1 then
		World.reset()
	end

	World.stepEntities()

	for entity in World.getEntities() do
		entity:update(delta)
	end

	for ship in World.getEntities(Ship) do
		for entity in World.getEntities() do
			if ship ~= entity then
				if ship:collidesWith(entity) and Network.getState() ~= NetworkState.Client then
					ship:remove()
				end

				if ship:checkForPhotonsCollidingWith(entity) then
					ship:destroyPhotonsCollidingWith(entity)

					if class.isInstance(entity, Ship) and entity.shieldStrength > 200 then
						SoundManager.play(Assets.sounds.shieldhit, {
							pitch = 1 + (-0.2 + (math.random() * 0.4))
						})

						entity.shieldStrength = 0
					elseif Network.getState() ~= NetworkState.Client and not class.isInstance(entity, Sun) then
						entity:remove()
					end
				end
			end
		end

		if Network.getState() == NetworkState.Server then
			if not ship:isLocalPlayer() and not ship:isAI() and not Network.getPeerByID(ship.peerID) then
				ship:remove()
			end
		end
	end
end

function World.draw()
	love.graphics.push('all')
		for entity in World.getEntities() do
			entity:draw()
		end

		love.graphics.push('all')
			love.graphics.translate(love.mouse.getPosition())
			love.graphics.setColor(Color.White:values())

			love.graphics.setLineWidth(1)
			love.graphics.setLineStyle('rough')

			love.graphics.circle('line', 0, 0, 6, 12)
			love.graphics.line(-12, 0, -6, 0)
			love.graphics.line(12, 0, 6, 0)
			love.graphics.line(0, -12, 0, -6)
			love.graphics.line(0, 12, 0, 6)
		love.graphics.pop()

		local time = timer:getTime() * 3

		if time < 1 then
			love.graphics.setColor((Color.White * (1 - time)):values())
			love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

			local offset = time * (love.graphics.getHeight() / 2)

			love.graphics.setColor(Color.Black:values())

			love.graphics.rectangle('fill', 0, -(love.graphics.getHeight() / 2) - offset, love.graphics.getWidth(), love.graphics.getHeight())
			love.graphics.rectangle('fill', 0, (love.graphics.getHeight() / 2) + offset, love.graphics.getWidth(), love.graphics.getHeight())
		end

		if Network.getState() == NetworkState.Client and Network.getServerState() == "connecting" then
			love.graphics.push('all')
				love.graphics.setColor(Color.White:values())
				love.graphics.setFont(Assets.fonts.Hyperspace_Bold.large)
				love.graphics.printf("Connecting" .. string.rep('.', (time / 2) % 4), love.graphics.getFont():getWidth(string.rep('.', (time / 2) % 4)) / 2, (love.graphics.getHeight() - love.graphics.getFont():getHeight()) / 2, love.graphics.getWidth(), 'center')
			love.graphics.pop()
		end

		love.graphics.setColor(Color.White:values())
		love.graphics.print(("Network State: %s"):format(table.find(NetworkState, Network.getState()) or "Unknown"), 10, 40)

		local offset = 60

		for peer in Network.getPeers() do
			love.graphics.print(("%s (%i): %ims"):format(Network.getUsername(peer:connect_id()), peer:connect_id(), peer:last_round_trip_time()), 10, offset)
			offset = offset + 20
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
		if Network.getState() ~= NetworkState.None then
			Network.close()
		end

		SoundManager.stopAll('sfx')

		return
	end

	-- Default spawns
	if Network.getState() ~= NetworkState.None then
		Network.broadcast("Reset")

		for peer in Network.getPeers() do
			World.addEntity(Ship(peer:connect_id(), Vector2(math.random(love.graphics.getWidth()), math.random(love.graphics.getHeight())), Color.fromHSV(1, 1, math.random(360))))
		end
	end

	if Network.getState() ~= NetworkState.Client then
		World.addEntity(Ship(Network.getID(), Vector2(love.graphics.getDimensions()) / 2, Color.White:copy()))

		for k = 1, math.random(5) do
			World.addEntity(Ship(-1, Vector2(math.random(love.graphics.getWidth()), math.random(love.graphics.getHeight())), Color.fromHSV(1, 1, math.random(360))))
		end
	end
end
