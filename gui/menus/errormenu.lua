ErrorMenu = Menu:extend("ErrorMenu")

function ErrorMenu:init(error)
	ErrorMenu.super.init(self, error)

	self:addComponent(ButtonComponent(Vector2(-1, -1), "OK", Assets.fonts.Hyperspace_Bold.large, function()
		GUI.popMenu()
	end))
end
