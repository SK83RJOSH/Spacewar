require('gui/components/textcomponent')

InputComponent = TextComponent:extend("InputComponent")

function InputComponent:init(position, text, placeholder, maxLength, filter)
	InputComponent.super.init(self, position, text)

	self.placeholder = placeholder
	self.maxLength = maxLength
	self.filter = filter
end

function InputComponent:update(delta)
	InputComponent.super.update(self, delta)

	self.bounds = Vector2(math.round(GUI.getBounds().x / 3), self.bounds.y)
end

function InputComponent:textinput(text)
	if not self.active or (self.filter and not self.filter:find(text)) then return end

	if not self.maxLength or #self.text < self.maxLength then
		self.text = self.text .. text
	end
end

function InputComponent:keypressed(key, isRepeat)
	if key == 'backspace' and #self.text > 0 then
		self.text = self.text:sub(0, #self.text - 1)
	end
end

function InputComponent:click()
	self.active = true
end

function InputComponent:draw(debug)
	love.graphics.push('all')
		love.graphics.setColor(0, 0, 0, (self.hover or self.active) and 150 or 100)
		love.graphics.rectangle('fill', self:getX(), self:getY(), self.bounds.x, self.bounds.y)

		local lineWidth = self.active and 2 or 1

		love.graphics.setColor(Color.White:values())
		love.graphics.setLineWidth(lineWidth)
		love.graphics.setLineStyle('rough')
		love.graphics.rectangle('line', self:getX() - (lineWidth - 1), self:getY() - (lineWidth - 1), self.bounds.x + (lineWidth - 1), self.bounds.y + (lineWidth - 1))

		love.graphics.translate(5, 0)

		if self.text ~= '' then
			InputComponent.super.draw(self, debug)
		elseif self.placeholder then
			love.graphics.print(self.placeholder, self:getX(), self:getY())
		end
	love.graphics.pop()
end
