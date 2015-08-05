MainMenu = Menu:extend("MainMenu")

function MainMenu:init()
	MainMenu.super.init(self, love.window.getTitle())

	self:addComponent(ButtonComponent(Vector2(-1, 200), "Play", Assets.fonts.Hyperspace_Bold.large, function()
		setGameState(GameState.Game)
	end))

	self:addComponent(ButtonComponent(Vector2(-1, 250), "Options", Assets.fonts.Hyperspace_Bold.large, function()
		GUI.pushMenu(OptionsMenu())
	end))

	self:addComponent(ButtonComponent(Vector2(-1, 300), "Quit", Assets.fonts.Hyperspace_Bold.large, function()
		love.event.quit()
	end))
end

function MainMenu:keypressed(key, isRepeat)
	if key == 'escape' then
		love.event.quit()
	end

	MainMenu.super.keypressed(self, key, isRepeat)
end

function MainMenu:gamepadpressed(joystick, button)
	if button == 'back' or button == 'b' then
		love.event.quit()
	end

	MainMenu.super.gamepadpressed(self, joystick, button)
end
