JoinMenu = Menu:extend("JoinMenu")

function JoinMenu:init()
	JoinMenu.super.init(self, "Join Game")

	local label = TextComponent(Vector2(-1, 175), "")

	self:addComponent(label)

	local input = InputComponent(Vector2(-1, 200), Settings.get('last_address', ""), "IP Address")

	self:addComponent(input)

	self:addComponent(ButtonComponent(Vector2(-1, 250), "Connect", Assets.fonts.Hyperspace_Bold.large, function()
		label:setText("", false)

		local host, port = input.text:split(":")

		local status, error = World.setNetworkState(NetworkState.Client, {
			address = host,
			port = tonumber(port)
		})

		if not status then
			label:setText(error, true)
		else
			GUI.popMenu()

			Settings.set('last_address', input.text)
			setGameState(GameState.Game)
		end
	end))

	self:addComponent(ButtonComponent(Vector2(-1, 300), "Cancel", Assets.fonts.Hyperspace_Bold.large, function()
		GUI.popMenu()
	end))
end
