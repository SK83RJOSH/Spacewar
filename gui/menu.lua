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

function Menu:mousepressed(x, y, button)
	if button ~= 'l' then return end

	for component in self:getComponents() do
		if (component.active or component.hover) and component.click then
			component:click()
		end
	end
end

function Menu:keypressed(key, isRepeat)
	if key == 'escape' and not isRepeat then
		GUI.popMenu()
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
