Explosion = SpaceWarEntity:extend("Explosion")

function Explosion:init(position, color, radius)
	SpaceWarEntity.init(self, radius, false)

	self.position = position
	self.color = Color(color.r, color.g, color.b, 0.65)
	self.radius = radius
	self.timer = Timer()
end

function Explosion:buildNetworkConstructor()
	return {
		{self.position:values()},
		{self.color:values()},
		self.radius
	}
end

function Explosion:buildNetworkUpdate()
	return {
		self.position.x,
		self.position.y
	}
end

function Explosion:applyNetworkUpdate(data)
	self.position.x, self.position.y = unpack(data)
end

function Explosion:update(delta)
	Explosion.super.update(self, delta)

	if self.timer:getTime() > 0.2 then
		self:remove()
	end
end

function Explosion:draw()
	Explosion.super.draw(self)

	love.graphics.push('all')
		local time = self.timer:getTime() * 60

		if time < 6 then
			love.graphics.setColor(Color.White:values())
		else
			love.graphics.setColor(self.color:values())
		end

		love.graphics.setBlendMode('additive')
		love.graphics.circle('fill', self.position.x, self.position.y, self.radius * (1 + time), 32)
	love.graphics.pop()
end
