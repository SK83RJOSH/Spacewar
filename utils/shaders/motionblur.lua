MotionBlur = {}

MotionBlur.numFrames = 16
MotionBlur.fadeBase = 0xf0

local canvases
local lastCanvas
local nextCanvas

function MotionBlur.reset()
	canvases = {}

	for i = 1, MotionBlur.numFrames do
		canvases[#canvases + 1] = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight(), 'rgba4')
	end
end

function MotionBlur.update()
	nextCanvas = table.remove(canvases, 1)
	lastCanvas = love.graphics.getCanvas()

	-- Thanks 0.10.0; remove a feature that was useful so I have to do convoluted things to accomplish tasks that used to be simple.
	love.graphics.setCanvas(nextCanvas)
	love.graphics.clear()
	love.graphics.setCanvas(lastCanvas)

	canvases[#canvases + 1] = nextCanvas
end

function MotionBlur.preDraw()
	lastCanvas = love.graphics.getCanvas()

	love.graphics.setCanvas(nextCanvas)
end

function MotionBlur.postDraw()
	love.graphics.setCanvas(lastCanvas)
end

function MotionBlur.draw()
	lastCanvas = love.graphics.getCanvas()

	love.graphics.push('all')
		for i, canvas in ipairs(canvases) do
			love.graphics.setColor(0xff, 0xff, 0xff, i == #canvases and 0xff or i / #canvases * MotionBlur.fadeBase)
			love.graphics.draw(canvas)
		end
	love.graphics.pop()

	love.graphics.setCanvas(lastCanvas)
end

return MotionBlur
