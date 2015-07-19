Timer = class("Timer")

function Timer:init(seconds)
	self:restart(seconds)
end

function Timer:restart(seconds)
	self.startTime = love.timer.getTime() - (seconds or 0)
end

function Timer:getTime()
	return love.timer.getTime() - self.startTime
end
