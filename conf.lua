io.stdout:setvbuf('no')

function love.conf(config)
	config.identity = 'Spacewar'
	config.version = '0.9.2'

	config.window.title = 'Spacewar!'
	config.window.icon = 'assets/images/icon.png' -- Due to a (possible) SDL bug this does not affect traybar icon
	config.window.fullscreentype = 'desktop'
	config.window.resizable = true
	config.window.minwidth = 960
	config.window.minheight = 640
end
