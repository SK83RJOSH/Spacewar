OptionsMenu = Menu:extend("OptionsMenu")

function OptionsMenu:init()
	OptionsMenu.super.init(self, love.window.getTitle())

	self:addComponent(ButtonComponent(Vector2(-1, 200), "Toggle Sound", Assets.fonts.Hyperspace_Bold.large, function()
		if SoundManager.getChannelVolume('master') > 0 then
			SoundManager.setChannelVolume('master', 0)
		else
			SoundManager.setChannelVolume('master', 0.025)
		end
	end))

	self:addComponent(ButtonComponent(Vector2(-1, 250), "Back", Assets.fonts.Hyperspace_Bold.large, function()
		GUI.popMenu()
	end))
end
