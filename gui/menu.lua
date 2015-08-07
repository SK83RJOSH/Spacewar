require('gui/menucomponent')

Menu = class("Menu")

function Menu:init(title)
	self.title = title
	self.components = {}

	self:addComponent(TextComponent(Vector2(-1, 100), self.title, Assets.fonts.Hyperspace_Bold.verylarge))
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

function Menu:selectNext()
	local loopComponent = false
	local activeComponent = false

	for component in self:getComponents() do
		if component.click or class.isInstance(component, SliderComponent) then
			if not loopComponent then
				loopComponent = component
			end

			if component.active then
				if activeComponent then
					activeComponent.active = false
					activeComponent = false
				end

				component.active = false
			elseif not activeComponent then
				component.active = true
				activeComponent = component
			end
		end
	end

	if not activeComponent and loopComponent then
		loopComponent.active = true
	end
end

function Menu:selectPrev()
	local inactiveComponent = false

	for component in self:getComponents() do
		if component.click or class.isInstance(component, SliderComponent) then
			if not inactiveComponent then
				inactiveComponent = component
			elseif not inactiveComponent.active then
				if component.active then
					inactiveComponent.active = true
				else
					inactiveComponent = component
				end
			end

			component.active = false
		end
	end

	if inactiveComponent and not inactiveComponent.active then
		inactiveComponent.active = true
	end
end

function Menu:clearActive()
	for component in self:getComponents() do
		component.active = false
	end
end

function Menu:mousepressed(x, y, button)
	for component in self:getComponents() do
		if component.hover and not component.active then
			component.active = button
		end
	end
end

function Menu:mousereleased(x, y, button)
	for component in self:getComponents() do
		if component.active == button then
			component.active = false

			if button == 'l' and component.hover and component.click then
				component:click()
			end
		end
	end
end

function Menu:keypressed(key, isRepeat)
	if (key == 'escape' or key == 'backspace') and not isRepeat then
		GUI.popMenu()

		if not GUI.getActiveMenu() then
			love.event.quit()
		end
	elseif key == 'down' then
		self:selectNext()
	elseif key == 'up' then
		self:selectPrev()
	elseif table.find({'left', 'right', 'return'}, key) and not GUI.isCursorActive() then
		for component in self:getComponents() do
			if component.active then
				if component.click and (key == 'return' or class.isInstance(component, ToggleComponent)) then
					component:click()
				elseif class.isInstance(component, SliderComponent) then
					if key == 'left' then
						component.value = math.clamp(component.value - 0.1, 0, 1)
					elseif key == 'right' then
						component.value = math.clamp(component.value + 0.1, 0, 1)
					end

					if component.changeCallback then
						component.changeCallback(component.value)
					end
				end
			end
		end
	end
end

function Menu:gamepadpressed(joystick, button)
	if button == 'back' or button == 'b'then
		GUI.popMenu()

		if not GUI.getActiveMenu() then
			love.event.quit()
		end
	elseif button == 'dpdown' then
		self:selectNext()
	elseif button == 'dpup' then
		self:selectPrev()
	elseif table.find({'dpleft', 'dpright', 'a'}, button) and not GUI.isCursorActive() then
		for component in self:getComponents() do
			if component.active then
				if component.click and (button == 'a' or class.isInstance(component, ToggleComponent)) then
					component:click()
				elseif class.isInstance(component, SliderComponent) then
					if button == 'dpleft' then
						component.value = math.clamp(component.value - 0.1, 0, 1)
					elseif button == 'dpright' then
						component.value = math.clamp(component.value + 0.1, 0, 1)
					end

					if component.changeCallback then
						component.changeCallback(component.value)
					end
				end
			end
		end
	else
		for component in self:getComponents() do
			if component.hover and not component.active then
				component.active = button
			end
		end
	end
end

function Menu:gamepadreleased(joystick, button)
	for component in self:getComponents() do
		if component.active == button then
			component.active = false

			if button == 'a' and component.hover and component.click then
				component:click()
			end
		end
	end
end

function Menu:update(delta)
	for component in self:getComponents() do
		component:update(delta)
	end
end

function Menu:draw(debug)
	for component in self:getComponents() do
		component:draw(debug)
	end
end

require('gui/menus/mainmenu')
require('gui/menus/optionsmenu')
