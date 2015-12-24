Bloom = {}

local lastCanvas

local canvas
local pass1
local pass2

function Bloom.reset()
	canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight(), 'rgba4')
	canvas:setWrap('mirroredrepeat') -- This is getting kind of annoying, the blur on edges is WAY too strong

	pass1 = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight(), 'rgba4')
	pass1:setWrap('mirroredrepeat') -- This is getting kind of annoying, the blur on edges is WAY too strong

	pass2 = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight(), 'rgba4')
	pass2:setWrap('mirroredrepeat') -- This is getting kind of annoying, the blur on edges is WAY too strong

	Assets.shaders.blur:send('canvas_size', {love.graphics.getDimensions()})
	Assets.shaders.blur:send('blur_amount', 50)
	Assets.shaders.blur:send('blur_scale', 1)
	Assets.shaders.blur:send('blur_strength', 0.25)
end

function Bloom.preDraw()
	lastCanvas = love.graphics.getCanvas()

	love.graphics.setCanvas(canvas)
	love.graphics.clear()
end

function Bloom.postDraw()
	love.graphics.setCanvas(lastCanvas)

	lastCanvas = love.graphics.getCanvas()


	love.graphics.push('all')
		love.graphics.setShader(Assets.shaders.blur)
		Assets.shaders.blur:send('horizontal', true)

		love.graphics.setCanvas(pass1)
		love.graphics.clear()
		love.graphics.draw(canvas)

		Assets.shaders.blur:send('horizontal', false)

		love.graphics.setCanvas(pass2)
		love.graphics.clear()
		love.graphics.draw(pass1)
	love.graphics.pop()

	love.graphics.setCanvas(lastCanvas)
	love.graphics.draw(canvas)

	love.graphics.push('all')
		love.graphics.setBlendMode('add')
		love.graphics.draw(pass2)
	love.graphics.pop()
end

return Bloom
