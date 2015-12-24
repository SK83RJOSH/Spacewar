Phosphor = {}

local canvas
local lastCanvas

function Phosphor.reset()
	canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight(), 'rgba4')
end

function Phosphor.preDraw()
	lastCanvas = love.graphics.getCanvas()

	love.graphics.setCanvas(canvas)
	love.graphics.clear()
end

function Phosphor.postDraw()
	love.graphics.setCanvas(lastCanvas)

	love.graphics.push('all')
		love.graphics.setShader(Assets.shaders.phosphor)
		love.graphics.draw(canvas)
	love.graphics.pop()
end

return Phosphor
