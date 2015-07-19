Debris = SpaceWarEntity:extend("Debris")

Debris.MAX_LIFETIME = 5
Debris.FADE_TIME = 1.5

function Debris:init(position, color)
	Debris.super.init(self, 0, true)

	self:addLine(Vector2(0, 0), Vector2(16, 0), color)

	local rotation = math.random() * (math.pi * 2)
	local sin = math.sin(rotation)
	local cos = math.cos(rotation)
	local offset = (math.random() * 6 * 2) - 6

	self.color = color
	self.creationTime = love.timer.getTime()
	self.disableCollisions = true
	self.rotationPerInterval = ((math.random() * 157 * 2) - 157) / 100
	self.rotationDeltaNextFrame = self.rotationPerInterval
	self.rotation = rotation
	self.velocity = Vector2(sin * 80, cos * -80)
	self.position = position + Vector2(cos * -offset - sin * -offset, cos * -offset + sin * -offset)
end

function Debris:update(delta)
	Debris.super.update(self, delta)

	local lifetime = love.timer.getTime() - self.creationTime

	if lifetime > Debris.MAX_LIFETIME - Debris.FADE_TIME then
		self.color.a = 255 * (1 - (lifetime - (Debris.MAX_LIFETIME - Debris.FADE_TIME)) / Debris.FADE_TIME)
	end

	if love.timer.getTime() - self.creationTime > Debris.MAX_LIFETIME then
		self:remove()
	end

	self.rotationDeltaNextFrame = (self.rotationPerInterval * delta)
end

function Debris:draw()
	Debris.super.draw(self, self.color)
end
