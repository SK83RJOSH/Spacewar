io.stdout:setvbuf('no')

function love.conf(config)
	config.identity = nil
	config.version = '0.9.2'
	config.console = false

	config.window.title = 'Spacewar!'
	config.window.icon = 'assets/images/icon.png' -- For use with future versions
	config.window.fullscreentype = 'desktop'
	config.window.resizable = true
	config.window.minwidth = 768
	config.window.minheight = 704
end
