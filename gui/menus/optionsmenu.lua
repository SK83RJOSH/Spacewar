OptionsMenu = Menu:extend("OptionsMenu")

function OptionsMenu:init()
	OptionsMenu.super.init(self, love.window.getTitle())

	self:addComponent(TextComponent(Vector2(-1, 200), "Sound Options", Assets.fonts.Hyperspace_Bold.normal))

	self:addComponent(SliderComponent(Vector2(-1, 235), "Master Volume", SoundManager.getChannelVolume('master'), function(value)
		SoundManager.setChannelVolume('master', value)
		Settings.set('master_volume', value)
	end))

	local offset = 260

	for channelName, channelParams in SoundManager.getChannels() do
		if channelName ~= 'master' then
			self:addComponent(SliderComponent(Vector2(-1, offset), channelName .. " Volume", channelParams.volume, function(value)
				SoundManager.setChannelVolume(channelName, value)
				Settings.set(channelName .. '_volume', value)
			end))

			offset = offset + 25
		end
	end

	self:addComponent(TextComponent(Vector2(-1, offset + 30), "Video Options", Assets.fonts.Hyperspace_Bold.normal))

	self:addComponent(ToggleComponent(Vector2(-1, offset + 65), "Fullscreen", love.window.getFullscreen(), function(value)
		love.window.setFullscreen(value)
		Settings.set('fullscreen', value)
	end))

	self:addComponent(ToggleComponent(Vector2(-1, offset + 90), "Phosphor", phosphor_shader, function(value)
		phosphor_shader = value
		Settings.set('phosphor_shader', value)
	end))

	self:addComponent(ToggleComponent(Vector2(-1, offset + 115), "Bloom", bloom_shader, function(value)
		bloom_shader = value
		Settings.set('bloom_shader', value)
	end))

	self:addComponent(ButtonComponent(Vector2(-1, offset + 165), "Back", Assets.fonts.Hyperspace_Bold.large, function()
		GUI.popMenu()
	end))
end
