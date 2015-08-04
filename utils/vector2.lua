Vector2 = class("Vector2")

function Vector2:init(x, y)
	assert(not x or type(x) == 'number', "You must supply a valid number for X!")
	assert(not y or type(y) == 'number', "You must supply a valid number for Y!")

	self.x = x or 0
	self.y = y or self.x
end

function Vector2:__tostring()
	return self.x .. ', ' .. self.y
end

function Vector2:__unm()
	return Vector2(-self.x, -self.y)
end

function Vector2:__add(addend)
	assert(class.isInstance(addend, Vector2), "Addend must be a valid Vector2!")

	return Vector2(self.x + addend.x, self.y + addend.y)
end

function Vector2:__sub(subtrahend)
	assert(class.isInstance(subtrahend, Vector2), "Subtrahend must be a valid Vector2!")

	return Vector2(self.x - subtrahend.x, self.y - subtrahend.y)
end

function Vector2:__mul(factor)
	assert(type(factor) == 'number' or class.isInstance(factor, Vector2), "Factor must be either a valid Vector2 or number!")

	if type(factor) == 'number' then
		return Vector2(self.x * factor, self.y * factor)
	else
		return Vector2(self.x * factor.x, self.y * factor.y)
	end
end

function Vector2:__div(devisor)
	assert(type(devisor) == 'number' or class.isInstance(devisor, Vector2), "Devisor must be either a valid Vector2 or number!")

	if type(devisor) == 'number' then
		return Vector2(self.x / devisor, self.y / devisor)
	else
		return Vector2(self.x / devisor.x, self.y / devisor.y)
	end
end

function Vector2:__eq(comparison)
	if class.isInstance(comparison, Vector2) then
		return self.x == comparison.x and self.y == comparison.y
	end

	return false
end

function Vector2:values()
	return self.x, self.y
end

function Vector2:copy()
	return Vector2(self:values())
end

function Vector2:length()
	return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vector2:angle()
	local dx, dy = self:normalized():values()

	return math.atan2(dy, dx)
end

function Vector2:abs()
	return Vector2(math.abs(self.x), math.abs(self.y))
end

function Vector2:normalized()
	local length = self:length()

	if length > 0 then
		return Vector2(self.x / length, self.y / length)
	else
		return Vector2.Zero:copy()
	end
end

function Vector2:distance(vector)
	assert(class.isInstance(vector, Vector2), "Supplied value must be a valid Vector2!")

	return math.sqrt(math.pow(self.x - vector.x, 2) + math.pow(self.y - vector.y, 2))
end

function Vector2:cross(vector)
	assert(class.isInstance(vector, Vector2), "Supplied value must be a valid Vector2!")

	return self.x * vector.x - self.y * vector.y
end

function Vector2:dot(vector)
	assert(class.isInstance(vector, Vector2), "Supplied value must be a valid Vector2!")

	local normalized = self:normalized()
	local vector = vector:normalized()

	return normalized.x * vector.x + normalized.y * vector.y
end

function Vector2:angleTo(vector)
	assert(class.isInstance(vector, Vector2), "Supplied value must be a valid Vector2!")

	return self:normalized():angle() - vector:normalized():angle()
end

function Vector2:rotate(radians)
	local cos = math.cos(radians)
	local sin = math.sin(radians)

	return Vector2((cos * self.x) - (sin * self.y), (sin * self.x) + (cos * self.y))
end

function Vector2:clamp(arg1, arg2)
	if class.isInstance(arg1, Vector2) then
		return Vector2(math.clamp(self.x, 0, arg1.x), math.clamp(self.y, 0, arg1.y))
	end

	return Vector2(math.clamp(self.x, arg1, arg2), math.clamp(self.y, arg1, arg2))
end

function Vector2:reflect(vector)
	assert(class.isInstance(vector, Vector2), "Supplied value must be a valid Vector2!")

	local dotProduct = self:dot(vector) * 2

	return Vector2(self.x - dotProduct * vector.x, self.y - dotProduct * vector.y)
end

Vector2.Zero = Vector2(0, 0)
Vector2.One = Vector2(1, 1)
Vector2.Up = Vector2(0, -1)
Vector2.Down = Vector2(0, 1)
Vector2.Left = Vector2(-1, 0)
Vector2.Right = Vector2(1, 0)
