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
		if updateTimer:getTime() > 1 / 32 then
			if Network.getState() == NetworkState.Server then
				for entity in World.getEntities() do
					Network.broadcast("EntityUpdate", {
						entity.__instance,
						entity:buildNetworkUpdate()
					})
				end
			else
				for ship in World.getEntities(Ship) do
					if ship.isLocalPlayer == Network.getID() then
						Network.send("EntityUpdate", {
							ship.__instance,
							ship:buildNetworkUpdate()
						})
					end
				end
			end

			updateTimer:restart()
		end

		for event in Network.getEvents() do
			if event.type == "connect" then
				if Network.getState() == NetworkState.Server then
					for entity in World.getEntities(entity) do
						Network.broadcast("EntityCreate", {
							entity.class.name,
							entity.__instance,
							entity:buildNetworkConstructor()
						})
					end

					World.addEntity(Ship(event.peer:connect_id(), Vector2(math.random(love.graphics.getWidth()), math.random(love.graphics.getHeight())), Color.fromHSV(1, 1, math.random(360))))
				end
			elseif event.type == "disconnect" then
				if Network.getState() == NetworkState.Client then
					Network.close()

					GUI.pushMenu(ErrorMenu("Connection Closed!"))
					setGameState(GameState.Menu)
				end
			elseif event.type == "receive" then
				local peer = event.peer
				local event, data = unpack(MessagePack.unpack(event.data))

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
							if not class.isInstance(entity, Ship) or entity.isLocalPlayer ~= Network.getID() then
								entity:applyNetworkUpdate(update)
							end
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
			end
		end
	end

	local shipCount = 0

	for ship in World.getEntities(Ship) do
		if Network.getState() == NetworkState.Client then
			if ship:isRemoved() and ship.isLocalPlayer == true then
				World.reset()
			end
		end

		if not ship:isRemoved() then
			shipCount = shipCount + 1
		end
	end

	if shipCount <= 1 and Network.getPeerCount() > 1 then
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
			if ship.isLocalPlayer and ship.isLocalPlayer ~= true and not Network.getPeerByID(ship.isLocalPlayer) then
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
		love.graphics.print("Network State: " .. (table.find(NetworkState, Network.getState()) or "Unknown"), 10, 40)
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
		for peer in Network.getPeers() do
			if peer:state() == "connected" then
				World.addEntity(Ship(peer:connect_id(), Vector2(math.random(love.graphics.getWidth()), math.random(love.graphics.getHeight())), Color.fromHSV(1, 1, math.random(360))))
			end
		end
	end

	if Network.getState() ~= NetworkState.Client then
		World.addEntity(Ship(true, Vector2(love.graphics.getDimensions()) / 2, Color.White))
	end
end
