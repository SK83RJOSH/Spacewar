require('gui/components/buttoncomponent')

ToggleComponent = ButtonComponent:extend("ToggleComponent")

function ToggleComponent:init(position, text, value, callback)
	ToggleComponent.super.init(self, position, text, false, function()
		self:toggled()
	end)

	self.toggle = value
	self.toggleCallback = callback
end

function ToggleComponent:toggled(value)
	self.toggle = not self.toggle

	if self.toggleCallback then
		self.toggleCallback(self.toggle)
	end
end

function ToggleComponent:update(delta)
	ToggleComponent.super.update(self, delta)

	self.bounds = Vector2(GUI.getBounds().x / 3, self.bounds.y)
end

function ToggleComponent:draw(debug)
	ToggleComponent.super.draw(self, debug)

	local text = self.toggle and "[on]" or "[off]"

	love.graphics.push('all')
		love.graphics.setColor(((self.hover or self.active) and Color.Red or Color.White):values())
		love.graphics.print(text, self:getX() + self.bounds.x - self.font:getWidth(text), self:getY())
	love.graphics.pop()
end
