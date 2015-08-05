TextComponent = MenuComponent:extend("TextComponent")

function TextComponent:init(position, text, font)
	self.text = text
	self.font = font or love.graphics.getFont()

	TextComponent.super.init(self, position, Vector2(self.font:getWidth(self.text), self.font:getHeight(self.text)))
end

function TextComponent:draw(debug)
	love.graphics.push('all')
		love.graphics.setFont(self.font)
		love.graphics.print(self.text, self:getX(), self:getY())
	love.graphics.pop()

	TextComponent.super.draw(self, debug)
end
