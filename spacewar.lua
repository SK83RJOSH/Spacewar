class "SpaceWar"

function SpaceWar:__init()
	Events:Subscribe("ModuleLoad", self, self.ModuleLoad)
end

function SpaceWar:ModuleLoad()
	self.starfield = StarField()
	self.sun = Sun()
	self.ships = {}

	Events:Subscribe("MouseDown", self, self.MouseDown)
	Events:Subscribe("MouseUp", self, self.MouseUp)
	Events:Subscribe("PreTick", self, self.PreTick)
	Events:Subscribe("Render", self, self.Render)
end

function SpaceWar:MouseDown(args)
	if args.button == 1 then
		-- self.mouseStart = Mouse:GetPosition()
	elseif args.button == 2 then
		table.insert(self.ships, Ship(true, Mouse:GetPosition(), Color.FromHSV(math.random(360), 1, 1)))

		if #self.ships == 1 then
			self.ships[#self.ships].isLocalPlayer = true
		end
	-- elseif args.button == 3 then
	-- 	for i = 0, 8 do
	-- 		table.insert(self.ships, ShipDebris(Mouse:GetPosition(), Color.GoldenRod))
	-- 	end
	end
end

function SpaceWar:MouseUp(args)
	if args.button == 1 and self.mouseStart then
		local direction = self.mouseStart - Mouse:GetPosition()
		local beam = PhotonBeam(Mouse:GetPosition(), Color.Yellow, math.atan2(direction.y, direction.x) - (math.pi / 2), direction)

		table.insert(self.ships, beam)

		self.mouseStart = nil
	end
end

function SpaceWar:PreTick(args)
	self.sun:RunFrame(args.delta)

	local explodingShips = {}

	for k, ship in ipairs(self.ships) do
		ship:RunFrame(args.delta)
		ship:DestroyPhotonsCollidingWith(self.sun)

		if ship:CollidesWith(self.sun) then
			explodingShips[k] = true
		end

		for j, enemyShip in ipairs(self.ships) do
			if k ~= j then
				if ship:CollidesWith(enemyShip) then
					explodingShips[k] = true
				end

				if enemyShip:CheckForPhotonsCollidingWith(ship) then
					if ship.shieldStrength > 200 then
						ship.shieldStrength = 0
						enemyShip:DestroyPhotonsCollidingWith(ship)
					else
						explodingShips[k] = true
					end
				end
			end
		end

		if ship.exploding and ship.lifetime - ship.exploded > 5 then
			table.remove(self.ships, k)
		end
	end

	for k, v in pairs(explodingShips) do
		if self.ships[k] then
			self.ships[k]:SetExploding(true)
		end
	end
end

function SpaceWar:Render(args)
	local delta = args.delta

	self.starfield:Render(delta)
	self.sun:Render(delta)

	for k, ship in ipairs(self.ships) do
		ship:Render(delta)
	end

	if self.mouseStart then
		Render:DrawLine(self.mouseStart, Mouse:GetPosition(), Color.Yellow)
	end

	Mouse:SetVisible(true)
end

SpaceWar = SpaceWar()
