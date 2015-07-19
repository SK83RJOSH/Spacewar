PhotonBeam = SpaceWarEntity:extend("PhotonBeam")

PhotonBeam.MAX_LIFETIME = 3
PhotonBeam.MAXIMUM_VELOCITY = 500

function PhotonBeam:init(position, color, velocity)
	PhotonBeam.super.init(self, 3, true)

	self.creationTime = love.timer.getTime()
	self.maximumVelocity = PhotonBeam.MAXIMUM_VELOCITY

	self.position = position

	self:addLine(Vector2(-2, -3), Vector2(-2, 3), color)
	self:addLine(Vector2(2, -3), Vector2(2, 3), color)

	self.velocity = velocity
	self.rotation = math.atan2(self.velocity.y, self.velocity.x) + (math.pi / 2)
end

function PhotonBeam:update(delta)
	self.rotation = math.atan2(self.velocity.y, self.velocity.x) + (math.pi / 2)

	if love.timer.getTime() - self.creationTime > PhotonBeam.MAX_LIFETIME then
		self:remove()
	end

	PhotonBeam.super.update(self, delta)
end

function PhotonBeam:draw()
	MotionBlur.preDraw()
		PhotonBeam.super.draw(self)
	MotionBlur.postDraw()
end

function PhotonBeam:remove()
	if self.removed then return end

	SoundManager.play(Assets.sounds.photon_death, {
		pitch = 1 + (-0.4 + (math.random() * 0.8))
	})

	PhotonBeam.super.remove(self)
end
