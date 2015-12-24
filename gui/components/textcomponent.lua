TextComponent = MenuComponent:extend("TextComponent")

function TextComponent:init(position, text, font)
	self.text = text
	self.font = font or love.graphics.getFont()
	self.textObject = love.graphics.newText(self.font, self.text)

	TextComponent.super.init(self, position, Vector2(self.textObject:getWidth(), self.font:getHeight()))
end

function TextComponent:setText(text, resize)
	self.text = text
	self.textObject = love.graphics.newText(self.font, self.text)

	if resize then
		self.bounds = Vector2(self.textObject:getWidth(), self.font:getHeight())
	end
end

function TextComponent:draw(debug)
	love.graphics.draw(self.textObject, self:getX(), self:getY())

	TextComponent.super.draw(self, debug)
end
