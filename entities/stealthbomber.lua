StealthBomber = SpaceWarEntity:extend("StealthBomber")

function StealthBomber:init(position, color)
	StealthBomber.super.init(self, 16, false)

	self.position = position
	self.color = color

	self:addLine(Vector2(0, -12), Vector2(-24, 12), self.color)
	self:addLine(Vector2(0, -12), Vector2(24, 12), self.color)

	self:addLine(Vector2(-24, 12), Vector2(-20, 13.5), self.color)
	self:addLine(Vector2(24, 12), Vector2(20, 13.5), self.color)

	self:addLine(Vector2(-20, 13.5), Vector2(-14, 8), self.color)
	self:addLine(Vector2(20, 13.5), Vector2(14, 8), self.color)

	self:addLine(Vector2(-14, 8), Vector2(-7.5, 14), self.color)
	self:addLine(Vector2(14, 8), Vector2(7.5, 14), self.color)

	self:addLine(Vector2(-7.5, 14), Vector2(-2.5, 10), self.color)
	self:addLine(Vector2(7.5, 14), Vector2(2.5, 10), self.color)

	self:addLine(Vector2(-2.5, 10), Vector2(0, 14), self.color)
	self:addLine(Vector2(2.5, 10), Vector2(0, 14), self.color)

	-- self:addLine(Vector2(0, -16), Vector2(-2, 0), self.color)
	-- self:addLine(Vector2(0, -16), Vector2(2, 0), self.color)
	--
	-- self:addLine(Vector2(16, 16), Vector2(0, -2), self.color)
	-- self:addLine(Vector2(16, 16), Vector2(0, 2), self.color)
	--
	-- self:addLine(Vector2(-16, 16), Vector2(0, 2), self.color)
	-- self:addLine(Vector2(-16, 16), Vector2(0, -2   ), self.color)
end

function StealthBomber:update(delta)
	for ship in World.getEntities(Ship) do
		local distance = ship.position:distance(self.position)
		local direction = (ship.position - self.position):normalized()

		self.rotation = direction:angle() + (math.pi / 2)
		self.velocity = direction * math.clamp(distance - 200, -150, 150)
	end

	StealthBomber.super.update(self, delta)
end
