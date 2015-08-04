Menu = class("Menu")

function Menu:init()
	self.components = {}
	self.mouseActive = true
	self.cursorPosition = Vector2(love.mouse.getPosition())
	self.cursorDelta = Vector2()
end

function Menu:isCursorActive()
	return self.cursorActive
end

function Menu:getCursorPosition()
	return self.cursorPosition
end

function Menu:getBounds()
	return Vector2(love.graphics.getDimensions())
end

function Menu:getComponents(type)
	if type then
		local filteredComponents = {}

		for k, component in ipairs(self.components) do
			if class.isInstance(component, type) then
				table.insert(filteredComponents, component)
			end
		end

		return table.iterator(filteredComponents)
	end

	return table.iterator(self.components)
end

function Menu:addComponent(component)
	assert(class.isInstance(component) and (class.isInstance(component, Component) or component.class:extends(Component)), "Component must be a valid MenuComponent!")

	component:setParent(self)

	table.insert(self.components, component)
end

function Menu:removeComponent(component)
	local componentIndex = table.find(self.components, component)

	if componentIndex then
		return table.remove(self.components, componentIndex)
	end

	return false
end

function Menu:mousemoved(x, y, dx, dy)
	self.cursorActive = true
	self.cursorPosition = Vector2(x, y)
	self.cursorDelta = Vector2()
end

function Menu:mousepressed(x, y, button)
	self.cursorActive = true
	self.cursorPosition = Vector2(x, y)
	self.cursorDelta = Vector2()

	for component in self:getComponents() do
		if component.click and component.active or component.hover then
			component:click()
		end
	end
end

function Menu:keypressed(key, isRepeat)
	self.cursorActive = true
	self.cursorPosition = Vector2(love.mouse.getPosition())
	self.cursorDelta = Vector2()

	if table.find({'up', 'down', 'left', 'right'}, key) then
		self.cursorActive = false
	end
end

function Menu:gamepadpressed(joystick, button)
	self.cursorActive = false
end

function Menu:gamepadaxis(joystick, axis, value)
	if axis == 'leftx' or axis == 'lefty' then
		self.cursorDelta = Vector2(axis == 'leftx' and value or joystick:getGamepadAxis('leftx'), axis == 'lefty' and value or joystick:getGamepadAxis('lefty'))

		if self.cursorDelta:length() < 0.2 then
			self.cursorDelta = Vector2()
		else
			self.cursorActive = true
			self.cursorDelta = self.cursorDelta * 10
		end
	end
end

function Menu:update()
	self.cursorPosition = (self.cursorPosition + self.cursorDelta):clamp(self:getBounds())

	for component in self:getComponents() do
		component:update()
	end
end

function Menu:draw(debug)
	for component in self:getComponents() do
		component:draw(debug)
	end

	if self:isCursorActive() then
		love.graphics.push('all')
			love.graphics.translate(self:getCursorPosition():values())
			love.graphics.setColor(Color.White:values())
			love.graphics.polygon('fill', 0, 0, 0, 25, 15, 20)
		love.graphics.pop()
	end
end

require('menus/mainmenu')
require('menus/menucomponent')
