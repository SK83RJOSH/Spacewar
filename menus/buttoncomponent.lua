ButtonComponent = TextComponent:extend("ButtonComponent")

function ButtonComponent:init(position, text, font, callback)
	self.callback = callback

	ButtonComponent.super.init(self, position, text, font)
end

function ButtonComponent:click()
	SoundManager.play(Assets.sounds.shieldhit, {
		channel = 'test'
	})

	if self.callback then
		self.callback()
	end
end

function ButtonComponent:draw(debug)
	love.graphics.push('all')
		love.graphics.setColor(((self.hover or self.active) and Color.Red or Color.White):values())
		ButtonComponent.super.draw(self, debug)
	love.graphics.pop()
end
