JoinMenu = Menu:extend("JoinMenu")

function JoinMenu:init()
	JoinMenu.super.init(self, "Join Game")

	local label = TextComponent(Vector2(-1, 175), "")

	self:addComponent(label)

	local input = InputComponent(Vector2(-1, 200), "", "IP Address", 15, "0123456789.")

	self:addComponent(input)

	self:addComponent(ButtonComponent(Vector2(-1, 250), "Connect", Assets.fonts.Hyperspace_Bold.large, function()
		label:setText("", false)

		if not input.text:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") then
			label:setText("Invalid Address!", true)
		end
	end))

	self:addComponent(ButtonComponent(Vector2(-1, 300), "Cancel", Assets.fonts.Hyperspace_Bold.large, function()
		GUI.popMenu()
	end))
end
