require('gui/components/textcomponent')

SliderComponent = TextComponent:extend("SliderComponent")

function SliderComponent:init(position, text, value, callback)
	SliderComponent.super.init(self, position, text)

	self.value = math.clamp(value, 0, 1)
	self.changeCallback = callback
end

function SliderComponent:update(delta)
	SliderComponent.super.update(self, delta)

	self.bounds = Vector2(math.round(GUI.getBounds().x / 3), self.bounds.y)

	if self.active and GUI.isCursorActive() then
		local value = math.clamp((GUI.getCursorPosition().x - self:getX()) / self.bounds.x, 0, 1)

		if value ~= self.value and self.changeCallback then
			self.changeCallback(value)
		end

		self.value = value
	end
end

function SliderComponent:draw(debug)
	love.graphics.push('all')
		love.graphics.setColor(0, 0, 0, (self.hover or (not GUI.isCursorActive() and self.active)) and 150 or 100)
		love.graphics.rectangle('fill', self:getX(), self:getY(), self.bounds.x, self.bounds.y)

		love.graphics.setColor((((self.hover or self.active) and Color.White or Color.Red) - Color(0, 0, 0, 200)):values())
		love.graphics.rectangle('fill', self:getX(), self:getY(), math.round(self.bounds.x * self.value), self.bounds.y)

		love.graphics.setColor(Color.White:values())
		love.graphics.setLineStyle('rough')
		love.graphics.rectangle('line', self:getX(), self:getY(), self.bounds.x, self.bounds.y)

		love.graphics.translate(5, 0)
		SliderComponent.super.draw(self, debug)
	love.graphics.pop()
end
