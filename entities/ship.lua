local ForwardThrusters = VectorEntity:extend("ForwardThrusters")

ForwardThrusters.DEFAULT_COLOR = Color(255, 255, 102)

function ForwardThrusters:init(ship)
	ForwardThrusters.super.init(self, 0)

	self:addLine(Vector2(0, 12), Vector2(0, 19), ForwardThrusters.DEFAULT_COLOR)
	self:addLine(Vector2(1, 12), Vector2(6, 19), ForwardThrusters.DEFAULT_COLOR)
	self:addLine(Vector2(4, 12), Vector2(11, 19), ForwardThrusters.DEFAULT_COLOR)
	self:addLine(Vector2(-1, 12), Vector2(-6, 19), ForwardThrusters.DEFAULT_COLOR)
	self:addLine(Vector2(-4, 12), Vector2(-11, 19), ForwardThrusters.DEFAULT_COLOR)

	self.ship = ship
end

function ForwardThrusters:draw()
	self.rotation = self.ship.rotation
	self.position = self.ship.position

	ForwardThrusters.super.draw(self)
end

local ReverseThrustersLeft = VectorEntity:extend("ReverseThrustersLeft")

ReverseThrustersLeft.DEFAULT_COLOR = Color(255, 255, 102)

function ReverseThrustersLeft:init(ship)
	ReverseThrustersLeft.super.init(self, 0)

	self:addLine(Vector2(-8.875, 10.5), Vector2(-14.85, 10.5), ReverseThrustersLeft.DEFAULT_COLOR)
	self:addLine(Vector2(-8.875, 10.5), Vector2(-13.765, 5.61), ReverseThrustersLeft.DEFAULT_COLOR)
	self:addLine(Vector2(-8.875, 10.5), Vector2(-7.85, 3.5), ReverseThrustersLeft.DEFAULT_COLOR)

	self.ship = ship
end

function ReverseThrustersLeft:draw()
	self.rotation = self.ship.rotation
	self.position = self.ship.position

	ReverseThrustersLeft.super.draw(self)
end

local ReverseThrustersRight = VectorEntity:extend("ReverseThrustersRight")

ReverseThrustersRight.DEFAULT_COLOR = Color(255, 255, 102)

function ReverseThrustersRight:init(ship)
	ReverseThrustersRight.super.init(self, 0)

	self:addLine(Vector2(8.875, 10.5), Vector2(14.85, 10.5), ReverseThrustersRight.DEFAULT_COLOR)
	self:addLine(Vector2(8.875, 10.5), Vector2(13.765, 5.61), ReverseThrustersRight.DEFAULT_COLOR)
	self:addLine(Vector2(8.875, 10.5), Vector2(7.85, 3.5), ReverseThrustersRight.DEFAULT_COLOR)

	self.ship = ship
end

function ReverseThrustersRight:draw()
	self.rotation = self.ship.rotation
	self.position = self.ship.position

	ReverseThrustersRight.super.draw(self)
end

Ship = SpaceWarEntity:extend("Ship")

Ship.PHOTON_BEAM_FIRE_INTERVAL = 0.5
Ship.MAXIMUM_SHIP_THRUST = 150
Ship.SHIP_DEBRIS_PIECES = 6

function Ship:init(peerID, position, color, decoration, power, weapon)
	Ship.super.init(self, 11, true)

	self.peerID = peerID
	self.position = position
	self.color = color

	self.photons = {}
	self.forwardThrusters = ForwardThrusters(self)
	self.reverseThrustersLeft = ReverseThrustersLeft(self)
	self.reverseThrustersRight = ReverseThrustersRight(self)
	self.fade = 255
	self.decoration = decoration or math.random(0, 4)
	self.power = power or math.random(0, 2)
	self.weapon = weapon or math.random(0, 2)
	self.shieldStrength = 0

	self.forwardThrusterActive = false
	self.reverseThrusterActive = false

	self.lastThrust = 0
	self.lastPhoton = 0

	self.vkLeft = 0
	self.vkRight = 0
	self.vkForward = 0
	self.vkReverse = 0
	self.vkFire = 0

	self:buildGeometry()
end

function Ship:isAI()
	return self.peerID == -1
end

function Ship:isPlayer()
	return not self:isAI()
end

function Ship:isLocalPlayer()
	return Network.getID() == self.peerID
end

function Ship:buildNetworkConstructor()
	return {
		self.peerID,
		{self.position:values()},
		{self.color:values()},
		self.decoration,
		self.power,
		self.weapon
	}
end

function Ship:buildGeometry()
	self:clearLines()

	self:addLine(Vector2(-9, 12), Vector2(0, -12), self.color)
	self:addLine(Vector2(0, -12), Vector2(9, 12), self.color)
	self:addLine(Vector2(9, 12), Vector2(-9, 12), self.color)

	if self.decoration == 1 then
		self:addLine(Vector2(0, -12), Vector2(-0, 12), self.color)
		self:addLine(Vector2(4.5, 0), Vector2(-4.5, 0), self.color)
	elseif self.decoration == 2 then
		self:addLine(Vector2(0, -12), Vector2(-0, 12), self.color)
		self:addLine(Vector2(4.5, 0), Vector2(-4.5, 0), self.color)
		self:addLine(Vector2(2.5, -6), Vector2(-9, 12), self.color)
		self:addLine(Vector2(9, 12), Vector2(-2.5, -6), self.color)
	elseif self.decoration == 3 then
		self:addLine(Vector2(0, -12), Vector2(0, 12), self.color)
		self:addLine(Vector2(2, -8), Vector2(2, 12), self.color)
		self:addLine(Vector2(-2, -8), Vector2(-2, 12), self.color)
	elseif self.decoration == 4 then
		self:addLine(Vector2(-12, 12), Vector2(-3, -12), self.color)
		self:addLine(Vector2(-17, 4), Vector2(-11, -10), self.color)
		self:addLine(Vector2(-17, 4), Vector2(-10, 7), self.color)
		self:addLine(Vector2(-11, -10), Vector2(-3, -7), self.color)
	end
end

function Ship:buildNetworkUpdate()
	return {
		self.position.x,
		self.position.y,
		self.velocity.x,
		self.velocity.y,
		self.rotation,
		self.vkLeft,
		self.vkRight,
		self.vkForward,
		self.vkReverse,
		self.vkFire
	}
end

function Ship:applyNetworkUpdate(data)
	self.position.x,
	self.position.y,
	self.velocity.x,
	self.velocity.y,
	self.rotation,
	self.vkLeft,
	self.vkRight,
	self.vkForward,
	self.vkReverse,
	self.vkFire = unpack(data)
end

function Ship:update(delta)
	for k, beam in ipairs(self.photons) do
		beam:update(delta)

		if beam:isRemoved() then
			table.remove(self.photons, k)
		end
	end

	if self.power == 1 then
		if #self.photons > 0 then
			self.fade = 255
		elseif self.fade > 0 then
			if self:isLocalPlayer() and self.fade == 255 then
				SoundManager.play(Assets.sounds.cloak, {
					channel = 'sfx',
					pitch = 1 + (-0.4 + (math.random() * 0.8))
				})
			end

			self.fade = self.fade - (420 * delta)

			if self.fade < 0 then
				self.fade = 0
			end

			if self:isLocalPlayer() and self.fade < 50 then
				self.fade = 128
			end
		end
	elseif self.power == 2 then
		if self.shieldStrength < 255 then
			self.shieldStrength = self.shieldStrength + (84 * delta)
		end
	end

	-- DEBUG CODE
		if self:isAI() then
			local minDistance = 0
			local targetShip = false

			for ship in World.getEntities(Ship) do
				if ship ~= self then
					local distance = ship.position:distance(self.position)

					if minDistance == 0 or distance < minDistance then
						targetShip = ship
						minDistance = distance
					end
				end
			end

			if targetShip then
				local dFactor = minDistance / (self.weapon == 2 and 500 or 275)
				local direction = ((targetShip.position + (targetShip.velocity - self.velocity * dFactor)) - self.position):normalized()
				local dot = Vector2(math.cos(self.rotation), math.sin(self.rotation)):dot(direction)
				local angle = math.atan2(direction.x, -direction.y)
				local angleDelta = 0

				if math.abs(angle - self.rotation) < math.pi then
					angleDelta = (angle - self.rotation) * delta * 4
				elseif angle > self.rotation then
					angleDelta = (angle - self.rotation - (math.pi * 2)) * delta * 4
				else
					angleDelta = (angle - self.rotation + (math.pi * 2)) * delta * 4
				end

				self.vkForward = 0
				self.vkReverse = 0
				self.vkLeft = 0
				self.vkRight = 0

				if angleDelta > 0 then
					self.vkRight = math.clamp(angleDelta * 12, 0, 1)
				else
					self.vkLeft = math.clamp(-angleDelta * 12, 0, 1)
				end

				if math.abs(dot) < 0.4 then
					self.vkFire = 1
				else
					self.vkFire = 0
				end

				if minDistance > 100 then
					self.vkForward = 0.5
				else
					self.vkReverse = 1
				end
			else
				self.vkForward = 0
				self.vkReverse = 0
				self.vkLeft = 0
				self.vkRight = 0
				self.vkFire = 0
			end
		end
	-- DEBUG CODE

	if self:isLocalPlayer() then
		self.vkForward = love.keyboard.isDown('w') and 1 or 0
		self.vkReverse = love.keyboard.isDown('s') and 1 or 0
		self.vkLeft = love.keyboard.isDown('a') and 1 or 0
		self.vkRight = love.keyboard.isDown('d') and 1 or 0
		self.vkFire = love.keyboard.isDown(' ') and 1 or 0
	end

	if self.vkReverse ~= 0 or self.vkForward ~= 0 then
		self.forwardThrusterActive = false
		self.reverseThrusterActive = false

		local sign = 0

		if self.vkReverse ~= 0 then
			self.reverseThrusterActive = true
			sign = sign - self.vkReverse
		end

		if self.vkForward ~= 0 then
			self.forwardThrusterActive = true
			sign = sign + self.vkForward
		end

		if self.lastThrust == 0 then
			self.lastThrust = love.timer.getTime()
		end

		local factor = math.min(((love.timer.getTime() - self.lastThrust) / 0.5) + 0.2, 1)

		self.acceleration = Vector2(math.sin(self.rotation), -math.cos(self.rotation)) * sign * factor * Ship.MAXIMUM_SHIP_THRUST
	else
		self.forwardThrusterActive = false
		self.reverseThrusterActive = false
		self.lastThrust = 0
	end

	if self.vkLeft ~= 0 then
		self.rotationDeltaNextFrame = self.rotationDeltaNextFrame + (self.vkLeft * ((-math.pi / 2) * (delta / 0.4)))
	end

	if self.vkRight ~= 0 then
		self.rotationDeltaNextFrame = self.rotationDeltaNextFrame + (self.vkRight * ((math.pi / 2) * (delta / 0.4)))
	end

	if self.vkForward ~= 0 or self.vkReverse ~= 0 or self.vkLeft ~= 0 or self.vkRight ~= 0 then
		if not self.thrust then
			self.thrust = SoundManager.play(Assets.sounds.engine, {
				channel = 'sfx',
				loop = true,
				time = 0.01
			})
		end

		if self.thrust then
			self.thrust:setPitch(1 + (-0.4 + (math.random() * 0.8)))
		end
	else
		if self.thrust then
			self.thrust:stop()

			SoundManager.play(Assets.sounds.engine, {
				channel = 'sfx',
				pitch = 1.5 + (math.random() * 0.5)
			})

			self.thrust = nil
		end
	end

	if self.vkFire ~= 0 and love.timer.getTime() - Ship.PHOTON_BEAM_FIRE_INTERVAL > self.lastPhoton then
		self.lastPhoton = love.timer.getTime()

		local sin = math.sin(self.rotation)
		local cos = math.cos(self.rotation)
		local speed = 275

		if self.weapon == 1 then
			table.insert(self.photons, PhotonBeam(self.position + (Vector2(-sin, cos) * -12), self.color, self.velocity - (Vector2(sin, -cos) * speed)))
		end

		if self.weapon == 2 then
			speed = 500
		end

		local sound = "shoot" .. math.random(1, 3)

		SoundManager.play(Assets.sounds["shoot" .. math.random(1, 3)], {
			channel = 'sfx',
			pitch = 1 + (-0.2 + (math.random() * 0.4))
		})

		table.insert(self.photons, PhotonBeam(self.position + (Vector2(-sin, cos) * -12), self.color, self.velocity - (Vector2(-sin, cos) * speed)))
	end

	Ship.super.update(self, delta)

	self.forwardThrusters:update(delta)
	self.reverseThrustersLeft:update(delta)
	self.reverseThrustersRight:update(delta)
end

function Ship:draw()
	if self.forwardThrusterActive and math.random(3) > 1 then
		self.forwardThrusters:draw()
	end

	if math.random(3) > 1 then
		if self.reverseThrusterActive then
			self.reverseThrustersLeft:draw()
			self.reverseThrustersRight:draw()
		elseif self.vkLeft ~= 0 and self.vkRight == 0 then
			self.reverseThrustersLeft:draw()
		elseif self.vkRight ~= 0 and self.vkLeft == 0 then
			self.reverseThrustersRight:draw()
		end
	end

	for k, beam in ipairs(self.photons) do
		beam:draw()
	end

	love.graphics.push('all')
		love.graphics.setColor(Color.White:values())

		local username = Network.getUsername(self.peerID)

		if self:isLocalPlayer() then
			username = "You"
		elseif self:isAI() then
			username = "Bot"
		end

		love.graphics.print(username, self.position.x - (love.graphics.getFont():getWidth(username) / 2), self.position.y - 40)
	love.graphics.pop()

	if self.power == 1 and self.fade < 255 then
		if self:isLocalPlayer() then
			Ship.super.draw(self, Color(self.color.r, self.color.g, self.color.b, self.fade))
		else
			MotionBlur.preDraw()
				Ship.super.draw(self, Color(self.color.r, self.color.g, self.color.b, self.fade))
			MotionBlur.postDraw()
		end

		return
	elseif self.power == 2 then
		local shieldColor = Color(175, 143, 0, self.shieldStrength / 8)
		local rotationClockwise = love.timer.getTime() / 0.5
		local rotationCounter = -rotationClockwise

		local x1 = 28 * math.cos(rotationClockwise)
		local y1 = 28 * math.sin(rotationClockwise)
		local x2 = 28 * math.cos(rotationCounter)
		local y2 = 28 * math.sin(rotationCounter)

		love.graphics.push('all')
			love.graphics.setColor(shieldColor:values())

			love.graphics.polygon('fill', {
				self.position.x - x1, self.position.y - y1,
				self.position.x + y1, self.position.y - x1,
				self.position.x + x1, self.position.y + y1,
				self.position.x - y1, self.position.y + x1
			})

			love.graphics.polygon('fill', {
				self.position.x - x2, self.position.y - y2,
				self.position.x + y2, self.position.y - x2,
				self.position.x + x2, self.position.y + y2,
				self.position.x - y2, self.position.y + x2
			})
		love.graphics.pop()
	end

	Ship.super.draw(self)
end

function Ship:remove()
	if not self.removed then
		SoundManager.play(Assets.sounds.explosion, {
			channel = 'sfx',
			pitch = 1 + (-0.2 + (math.random() * 0.4))
		})

		if self.thrust then
			self.thrust:stop()
		end

		if Network.getState() ~= NetworkState.Client then
			for i = 0, Ship.SHIP_DEBRIS_PIECES do
				World.addEntity(Explosion(self.position, self.color, self.collisionRadius))
				World.addEntity(Debris(self.position, self.color))
			end
		end
	end

	Ship.super.remove(self)
end

function Ship:destroyPhotonsCollidingWith(target)
	for k, photon in ipairs(self.photons) do
		if photon:collidesWith(target) then
			table.remove(self.photons, k)
		end
	end
end

function Ship:checkForPhotonsCollidingWith(target)
	for k, photon in ipairs(self.photons) do
		if photon:collidesWith(target) then
			return true
		end
	end

	return false
end
