function math.clamp(value, min, max)
	return math.min(max, math.max(min, value))
end

function math.round(value)
	return math.floor(value + 0.5)
end

function math.lerp(value, value2, fraction)
	return value + ((value2 - value) * fraction)
end
