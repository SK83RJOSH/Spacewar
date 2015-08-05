require('gui/menu')

GUI = {}

local cursorActive = true
local cursorPosition = Vector2()
local cursorDelta = Vector2()

function GUI.isCursorActive()
	return cursorActive
end

function GUI.getCursorPosition()
	return cursorPosition
end

function GUI.getBounds()
	return Vector2(love.graphics.getDimensions())
end

function GUI.resetCursor()
	cursorActive = true
	cursorPosition = Vector2(love.mouse.getPosition())
	cursorDelta = Vector2()
end

local menuStack = Stack(Menu)

function GUI.pushMenu(menu)
	menuStack:push(menu)
end

function GUI.popMenu()
	menuStack:pop()
end

function GUI.getActiveMenu()
	return menuStack:peek()
end

function GUI.mousemoved(x, y, dx, dy)
	GUI.resetCursor()
end

function GUI.mousepressed(x, y, button)
	GUI.resetCursor()

	if GUI.getActiveMenu() then
		GUI.getActiveMenu():mousepressed(x, y, button)
	end
end

function GUI.keypressed(key, isRepeat)
	GUI.resetCursor()

	if table.find({'up', 'down', 'left', 'right'}, key) then
		cursorActive = false
	end

	if GUI.getActiveMenu() then
		GUI.getActiveMenu():keypressed(key, isRepeat)
	end
end

function GUI.gamepadpressed(joystick, button)
	if table.find({'dpup', 'dpdown', 'dpleft', 'dpright'}, button) then
		cursorActive = false
	end

	if GUI.getActiveMenu() then
		GUI.getActiveMenu():gamepadpressed(joystick, button)
	end
end

function GUI.gamepadaxis(joystick, axis, value)
	if axis == 'leftx' or axis == 'lefty' then
		cursorDelta = Vector2(axis == 'leftx' and value or joystick:getGamepadAxis('leftx'), axis == 'lefty' and value or joystick:getGamepadAxis('lefty'))

		if cursorDelta:length() < 0.2 then
			cursorDelta = Vector2()
		else
			cursorActive = true
			cursorDelta = cursorDelta * 10
		end
	end
end

function GUI.update(delta)
	cursorPosition = (cursorPosition + cursorDelta):clamp(GUI.getBounds())

	if GUI.getActiveMenu() then
		GUI.getActiveMenu():update(delta)
	end
end

function GUI.draw()
	if GUI.getActiveMenu() then
		GUI.getActiveMenu():draw()
	end

	if GUI.isCursorActive() then
		love.graphics.push('all')
			love.graphics.translate(GUI.getCursorPosition():values())
			love.graphics.setColor(Color.White:values())
			love.graphics.polygon('fill', 0, 0, 0, 25, 15, 20)
		love.graphics.pop()
	end
end

GUI.resetCursor()
