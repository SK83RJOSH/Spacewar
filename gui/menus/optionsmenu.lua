OptionsMenu = Menu:extend("OptionsMenu")

function OptionsMenu:init()
	OptionsMenu.super.init(self, love.window.getTitle())

	self:addComponent(ToggleComponent(Vector2(-1, 200), "Mute Sound", SoundManager.getChannelVolume('master') == 0, function(value)
		if value then
			SoundManager.setChannelVolume('master', 0)
		else
			SoundManager.setChannelVolume('master', 0.025)
		end
	end))

	self:addComponent(ToggleComponent(Vector2(-1, 225), "Fullscreen", love.window.getFullscreen(), function(value)
		love.window.setFullscreen(value)
	end))

	self:addComponent(ButtonComponent(Vector2(-1, 275), "Back", Assets.fonts.Hyperspace_Bold.large, function()
		GUI.popMenu()
	end))
end
