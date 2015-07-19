require('utils/class')
require('utils/math')
require('utils/table')

require('utils/color')
require('utils/json')
require('utils/timer')
require('utils/vector2')

require('utils/shaders/bloom')
require('utils/shaders/motionblur')
require('utils/shaders/phosphor')
require('utils/shaders/starfield')

require('assetloader')
require('soundmanager')
require('world')

function love.load()
	love.graphics.setFont(Assets.fonts.Hyperspace_Bold.default)

	SoundManager.setChannelVolume('default', 0.025)

	love.resize()
end

function love.resize()
	Bloom.reset()
	MotionBlur.reset()
	Phosphor.reset()
	StarField.reset()
end

function love.mousepressed(x, y, button)
	if not game_started then
		game_started = true
		World.reset()
	else
		if button == 'l' then
			World.addEntity(
				PhotonBeam(
					Vector2(x, y),
					Color.FromHSV(math.random(0, 360), 1, 1),
					Vector2((math.random() * 2) - 1, (math.random() * 2) - 1) * 500
				)
			)
		elseif button == 'm' then
			World.addEntity(Sun(Vector2(x, y)))
		elseif button == 'r' then
			local isLocalPlayer = true

			for ship in World.getEntities(Ship) do
				if ship.isLocalPlayer then
					isLocalPlayer = false
				end
			end

			World.addEntity(Ship(isLocalPlayer, Vector2(x, y), Color.FromHSV(math.random(0, 360), 1, 1)))
		end
	end
end

function love.keypressed(key, isRepeat)
	if isRepeat then return end

	if key == 'r' and game_started then
		game_started = false
		World.reset(true)
	elseif key == 'f11' then
		love.window.setFullscreen(not love.window.getFullscreen())
	elseif key == 'escape' then
		love.event.quit()
	elseif not game_started then
		game_started = true
		World.reset()
	end
end

function love.update(delta)
	SoundManager.update()

	if game_started then
		World.update(delta)
	end

	collectgarbage('step', 512)
end

function love.draw()
	Phosphor.preDraw()
		Bloom.preDraw()
			StarField.draw()

			if not game_started then
				love.graphics.push('all')
					love.graphics.setFont(Assets.fonts.Hyperspace_Bold.verylarge)

					local text = 'Spacewar!'
					local textWidth = love.graphics.getFont():getWidth(text)
					local textHeight = love.graphics.getFont():getHeight(text)

					love.graphics.print(text, (love.graphics.getWidth() - textWidth) / 2, (love.graphics.getHeight() / 2) - textHeight)

					if love.timer.getTime() % 2 > 0.5 then
						love.graphics.setFont(Assets.fonts.Hyperspace_Bold.large)

						local text = 'Press any key to begin.'
						local textWidth = love.graphics.getFont():getWidth(text)
						local textHeight = love.graphics.getFont():getHeight(text)

						love.graphics.print(text, (love.graphics.getWidth() - textWidth) / 2, (love.graphics.getHeight() / 2) + textHeight)
					end
				love.graphics.pop()
			else
				MotionBlur.update()
					World.draw()
				MotionBlur.draw()
			end
		Bloom.postDraw()
	Phosphor.postDraw()

	local stats = love.graphics.getStats()
	local fps = love.timer.getFPS()
	local ram = collectgarbage('count') / 1024
	local vram = stats.texturememory / 1024 / 1024
	local drawcalls = stats.drawcalls
	local string = ("FPS: %i, RAM: %.2fMB, VRAM: %.2fMB, Drawcalls: %i"):format(fps, ram, vram, drawcalls)

	love.graphics.print(string, 10, 10)
end
