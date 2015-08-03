Menu = class("Menu")

function Menu:init()
	self.components = {}
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
	assert(class.isInstance(component, MenuComponent), "Component must be a valid MenuComponent!")

	component:setParent(self)

	table.insert(self.components, componentIndex)
end

function Menu:removeComponent(component)
	local componentIndex = table.find(self.components, component)

	if componentIndex then
		return table.remove(self.components, componentIndex)
	end

	return false
end

function Menu:update(delta)
	for component in self:getComponents() do
		component:update(delta)
	end
end

function Menu:draw()
	for component in self:getComponents() do
		component:draw()
	end
end

require('menus/menucomponent')
