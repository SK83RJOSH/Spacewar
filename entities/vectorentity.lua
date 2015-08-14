VectorEntity = class("VectorEntity")

local DEFAULT_MAXIMUM_VELOCITY = 450
local instances = 0

function VectorEntity:init(collisionRadius)
	instances = instances + 1
	self.__instance = instances

	self.collisionRadius = collisionRadius

	self.lines = {}

	self.rotation = 0
	self.rotationDeltaNextFrame = 0
	self.rotationDeltaLastFrame = 0

	self.acceleration = Vector2()
	self.accelerationLastFrame = Vector2()

	self.velocity = Vector2()
	self.position = Vector2()
	self.positionLastFrame = Vector2()

	self.disableCollisions = false
	self.maximumVelocity = DEFAULT_MAXIMUM_VELOCITY
end

function VectorEntity:__eq(comparison)
	return class.isInstance(comparison) and (class.isInstance(comparison, VectorEntity) or comparison.class:extends(VectorEntity)) and self.__instance == comparison.__instance
end

function VectorEntity:addLine(position1, position2, color)
	table.insert(self.lines, {
		position1 = position1,
		position2 = position2,
		color = color
	})
end

function VectorEntity:clearLines()
	self.lines = {}
end

function VectorEntity:resetVelocity()
	self.velocity = Vector2()
end

function VectorEntity:update(delta)
	self.rotation = self.rotation + self.rotationDeltaNextFrame
	self.rotationDeltaLastFrame = self.rotationDeltaNextFrame
	self.rotationDeltaNextFrame = 0

	while self.rotation >= math.pi * 2 do
		self.rotation = self.rotation - (math.pi * 2)
	end

	while self.rotation <= -math.pi * 2 do
		self.rotation = self.rotation + (math.pi * 2)
	end

	self.velocity = self.velocity + (self.acceleration * delta)

	if self.velocity:length() > self.maximumVelocity then
		self.velocity = self.velocity:normalized() * self.maximumVelocity
	end

	self.position = self.position + (self.velocity * delta)

	self.accelerationLastFrame = self.acceleration
	self.acceleration = Vector2()

	if self.position.x > love.graphics.getWidth() then
		self.position.x = self.position.x - love.graphics.getWidth()
	elseif self.position.x < 0 then
		self.position.x = self.position.x + love.graphics.getWidth()
	end

	if self.position.y > love.graphics.getHeight() then
		self.position.y = self.position.y - love.graphics.getHeight()
	elseif self.position.y < 0 then
		self.position.y = self.position.y + love.graphics.getHeight()
	end
end

function VectorEntity:draw(color)
	love.graphics.push('all')
		love.graphics.translate(self.position:values())
		love.graphics.rotate(self.rotation)

		love.graphics.setLineWidth(1)
		love.graphics.setLineStyle('rough')

		for k, line in ipairs(self.lines) do
			love.graphics.setColor((color or line.color):values())
			love.graphics.line(line.position1.x, line.position1.y, line.position2.x, line.position2.y)
		end
	love.graphics.pop()
end

function VectorEntity:collidesWith(entity)
	if self.disableCollisions or entity.disableCollisions then
		return false
	end

	return self.collisionRadius + entity.collisionRadius > self.position:distance(entity.position)
end

function VectorEntity:getDistanceTraveledLastFrame()
	return self.positionLastFrame:distance(self.position)
end

function VectorEntity:remove()
	self.removed = true
end

function VectorEntity:isRemoved()
	return self.removed
end

require('entities/spacewarentity')
