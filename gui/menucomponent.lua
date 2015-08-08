MenuComponent = class("MenuComponent")

local instances = 0

function MenuComponent:init(position, bounds)
	instances = instances + 1
	self.__instance = instances

	self.position = position
	self.bounds = bounds

	self.parent = false
	self.active = false
	self.hover = false
end

function MenuComponent:__eq(comparison)
	return class.isInstance(comparison) and (class.isInstance(comparison, MenuComponent) or comparison.class:extends(MenuComponent)) and self.__instance == comparison.__instance
end

function MenuComponent:getX()
	if self.position.x == -1 then
		return math.round((GUI.getBounds().x - self.bounds.x) / 2)
	end

	return self.position.x
end

function MenuComponent:getY()
	if self.position.y == -1 then
		return math.round((GUI.getBounds().y - self.bounds.y) / 2)
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

	if GUI.isCursorActive() then
		if self:getX() <= GUI.getCursorPosition().x and self:getX() + self.bounds.x >= GUI.getCursorPosition().x then
			if self:getY() <= GUI.getCursorPosition().y and self:getY() + self.bounds.y >= GUI.getCursorPosition().y then
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

require('gui/components/buttoncomponent')
require('gui/components/inputcomponent')
require('gui/components/slidercomponent')
require('gui/components/textcomponent')
require('gui/components/togglecomponent')
