Stack = class("Stack")

function Stack:init(class)
	self.class = class or false
	self.items = {}
end

function Stack:empty()
	return #self.items == 0
end

function Stack:peek()
	if self:empty() then return false end

	return self.items[#self.items]
end

function Stack:pop()
	if self:empty() then return false end

	return table.remove(self.items, #self.items)
end

function Stack:push(item)
	if self.class then
		assert(class.isInstance(item) and (class.isInstance(item, self.class) or item.class:extends(self.class)), "Item must be a valid " .. (self.class.name or "Unknown Class"))
	end

	table.insert(self.items, item)
end

function Stack:search(item)
	return table.find(self.items, item)
end
