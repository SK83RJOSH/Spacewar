SoundManager = {}

local channels = {
	['default'] = {
		volume = 1
	}
}

function SoundManager.getChannels()
	return channels
end

function SoundManager.setChannelVolume(channel, volume)
	if not channels[channel] then
		channels[channel] = {
			volume = 1
		}
	end

	channels[channel].volume = volume
end

local sounds = {}

function SoundManager.stepSounds()
	local k = 1
	local sound = false

	while k <= #sounds do
		sound = sounds[k]

		if not sound then
			table.remove(sounds, k)
		else
			k = k + 1
		end
	end
end

function SoundManager.play(source, params)
	local params = params or {}

	params.channel = params.channel or 'default'
	params.time = params.time or false
	params.loop = params.loop or false
	params.pitch = math.max(params.pitch or 1, 0)
	params.volume = math.clamp(params.volume or 1, 0, 1)

	local source = source:clone()

	source:setLooping(params.loop)
	source:setPitch(params.pitch)
	source:setVolume(params.volume * channels[params.channel].volume)
	source:play()

	table.insert(sounds, {
		source = source,
		params = params
	})

	return source
end

function SoundManager.stop(source)
	for k, sound in ipairs(sounds) do
		if sound.source == source then
			sound.source:stop()
			table.remove(sounds, k) -- No need to use SoundManager.stepSounds() since return immediately afterwards

			return true
		end
	end

	return false
end

function SoundManager.stopAll(channel)
	for k, sound in ipairs(sounds) do
		if not channel or sound.params.channel == channel then
			sound.source:stop()
			sounds[k] = false
		end
	end

	SoundManager.stepSounds() -- We need to stepSounds to ensure ALL the removed sounds get cleaned up
end

function SoundManager.update()
	for k, sound in ipairs(sounds) do
		if sound.source:isStopped() then
			sounds[k] = false
		elseif sound.params.time and sound.params.time <= sound.source:tell('seconds') then
			if sound.params.loop then
				sound.source:rewind()
			else
				sound.source:stop()
			end
		end
	end

	SoundManager.stepSounds() -- We need to stepSounds to ensure ALL the removed sounds get cleaned up
end
