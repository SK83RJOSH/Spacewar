StarField = {}

local canvas

function StarField.reset()
	canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight(), 'rgba4')
end

function StarField.draw()
	Assets.shaders.starfield:send('timer', love.timer.getTime())

	love.graphics.push("all")
		love.graphics.setShader(Assets.shaders.starfield)
		love.graphics.draw(canvas)
	love.graphics.pop()
end
