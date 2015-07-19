SpaceWarEntity = VectorEntity:extend("SpaceWarEntity")

function SpaceWarEntity:init(collisionRadius, affectedByGravity)
	SpaceWarEntity.super.init(self, collisionRadius)

	self.affectedByGravity = affectedByGravity
end

function SpaceWarEntity:update(delta)
	if self.affectedByGravity then
		for sun in World.getEntities(Sun) do
			local distance = self.position:distance(sun.position)
			local factor = math.min(5200000 / math.pow(distance, 2), 150)
			local direction = (self.position - sun.position):normalized()

			self.acceleration = self.acceleration - (direction * factor)

			if not self.disableCollisions and sun:collidesWith(self) then
				self:remove()
				return
			end
		end
	end

	SpaceWarEntity.super.update(self, delta)
end

require('entities/debris')
require('entities/explosion')
require('entities/photonbeam')
require('entities/ship')
require('entities/stealthbomber')
require('entities/sun')
