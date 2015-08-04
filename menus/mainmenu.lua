MainMenu = Menu:extend("MainMenu")

function MainMenu:init()
	MainMenu.super.init(self)

	self:addComponent(TextComponent(Vector2(-1, 100), love.window.getTitle(), Assets.fonts.Hyperspace_Bold.verylarge))
	self:addComponent(ButtonComponent(Vector2(-1, 200), "Play", Assets.fonts.Hyperspace_Bold.large, function()
		setGameState(GameState.Game)
	end))
	self:addComponent(ButtonComponent(Vector2(-1, 250), "Quit", Assets.fonts.Hyperspace_Bold.large, function()
		love.event.quit()
	end))
end
