MenuComponent = class("MenuComponent")

function MenuComponent:init(position, bounds)
	self.position = position
	self.bounds = bounds

	self.parent = false
	self.active = false
	self.hover = false
end

function MenuComponent:getX()
	if self.position.x == -1 then
		return (self.parent:getBounds().x - self.bounds.x) / 2
	end

	return self.position.x
end

function MenuComponent:getY()
	if self.position.y == -1 then
		return (self.parent:getBounds().y - self.bounds.y) / 2
	end

	return self.position.y
end

function MenuComponent:getPosition()
	if self.position.x == -1 or self.position.y == -1 then
		return Vector2(self:getX(), self:getY())
	end

	return self.position
end

function MenuComponent:setParent(parent)
	assert(class.isInstance(parent) and (class.isInstance(parent, Menu) or parent.class:extends(Menu)), "Parent must be a valid Menu!")

	self.parent = parent
end

function MenuComponent:update()
	assert(self.parent, "MenuComponent instantiated without a parent!")

	self.hover = false

	if self.parent:isCursorActive() then
		local cursor = self.parent:getCursorPosition()

		if self:getX() <= cursor.x and self:getX() + self.bounds.x >= cursor.x then
			if self:getY() <= cursor.y and self:getY() + self.bounds.y >= cursor.y then
				self.hover = true
			end
		end
	end
end

function MenuComponent:draw(debug)
	if debug then
		love.graphics.push('all')
			love.graphics.setColor((self.hover and Color.Red or Color.White):values())
			love.graphics.rectangle('line', self:getX(), self:getY(), self.bounds.x, self.bounds.y)
		love.graphics.pop()
	end
end

require('menus/textcomponent')
