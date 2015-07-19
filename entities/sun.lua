Sun = SpaceWarEntity:extend("Sun")

Sun.SCALE_FACTOR = 14
Sun.DEFAULT_COLOR = Color(255, 255, 102, 255)
Sun.ROTATION_SPEED = math.pi / 4

function Sun:init(position)
	Sun.super.init(self, 2 * Sun.SCALE_FACTOR, false)

	self.position = position

	self:addLine(Vector2(2 * Sun.SCALE_FACTOR, 0), Vector2(-2 * Sun.SCALE_FACTOR, 0), Sun.DEFAULT_COLOR)
	self:addLine(Vector2(0, 2 * Sun.SCALE_FACTOR), Vector2(0, -2 * Sun.SCALE_FACTOR), Sun.DEFAULT_COLOR)
	self:addLine(Vector2(-1.4 * Sun.SCALE_FACTOR, 1.4 * Sun.SCALE_FACTOR), Vector2(1.4 * Sun.SCALE_FACTOR, -1.4 * Sun.SCALE_FACTOR), Sun.DEFAULT_COLOR)
	self:addLine(Vector2(1.4 * Sun.SCALE_FACTOR, 1.4 * Sun.SCALE_FACTOR), Vector2(-1.4 * Sun.SCALE_FACTOR, -1.4 * Sun.SCALE_FACTOR), Sun.DEFAULT_COLOR)
end

function Sun:update(delta)
	self.rotationDeltaNextFrame = Sun.ROTATION_SPEED * delta

	Sun.super.update(self, delta)
end
