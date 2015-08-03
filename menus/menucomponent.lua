MenuComponent = class("MenuComponent")

function MenuComponent:init()
	self.parent = nil
end

function MenuComponent:setParent(parent)
	self.parent = parent
end

function MenuComponent:getParent()
	return self.parent
end

function MenuComponent:update(delta)
	error('MenuComponent:update(delta) must be implemented!')
end

function MenuComponent:draw()
	error('MenuComponent:draw() must be implemented!')
end
