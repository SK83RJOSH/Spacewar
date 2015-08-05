require('utils/class')
require('utils/math')
require('utils/table')

require('utils/color')
require('utils/json')
require('utils/msgpack')
require('utils/stack')
require('utils/timer')
require('utils/vector2')

require('utils/shaders/bloom')
require('utils/shaders/motionblur')
require('utils/shaders/phosphor')
require('utils/shaders/starfield')

require('gui/gui')

require('assetloader')
require('soundmanager')
require('world')

GameState = { Menu = 1, Game = 2 }
game_state = GameState.Menu

function getGameState()
	return game_state
end

function setGameState(new_game_state)
	game_state = new_game_state

	if game_state == GameState.Menu then
		World.reset(true)
	else
		World.reset()
	end
end

function love.load()
	love.graphics.setFont(Assets.fonts.Hyperspace_Bold.default)
	love.mouse.setVisible(false)

	SoundManager.setChannelVolume('master', 0.025)
	GUI.pushMenu(MainMenu())

	love.resize()
end

function love.resize()
	Bloom.reset()
	MotionBlur.reset()
	Phosphor.reset()
	StarField.reset()
end

function love.mousemoved(x, y, dx, dy)
	GUI.mousemoved(x, y, dx, dy)
end

function love.mousepressed(x, y, button)
	if getGameState() == GameState.Menu then
		GUI.mousepressed(x, y, button)
	elseif getGameState() == GameState.Game then
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
	if getGameState() == GameState.Menu then
		GUI.keypressed(key, isRepeat)
	end

	if not isRepeat then
		if key == 'f11' then
			love.window.setFullscreen(not love.window.getFullscreen())
		else
			if getGameState() == GameState.Game then
				if key == 'r' or key == 'escape' then
					setGameState(GameState.Menu)
				end
			end
		end
	end
end

function love.gamepadpressed(joystick, button)
	if getGameState() == GameState.Menu then
		GUI.gamepadpressed(joystick, button)
	elseif getGameState() == GameState.Game then
		if button == 'back' or button == 'b' or button == 'start' then
			setGameState(GameState.Menu)
		end
	end
end

function love.gamepadaxis(joystick, axis, value)
	if getGameState() == GameState.Menu then
		GUI.gamepadaxis(joystick, axis, value)
	end
end

function love.update(delta)
	SoundManager.update()

	if getGameState() == GameState.Menu then
		GUI.update(delta)
	elseif getGameState() == GameState.Game then
		World.update(delta)
	end

	collectgarbage('step', 512)
end

function love.draw()
	Phosphor.preDraw()
		Bloom.preDraw()
			StarField.draw()

			if getGameState() == GameState.Menu then
				GUI.draw()
			elseif getGameState() == GameState.Game then
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
