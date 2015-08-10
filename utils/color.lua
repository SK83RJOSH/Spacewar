Color = class("Color")

function Color:init(r, g, b, a)
	assert(not r or type(r) == 'number', "You must supply a valid number for R!")
	assert(not g or type(g) == 'number', "You must supply a valid number for G!")
	assert(not b or type(b) == 'number', "You must supply a valid number for B!")
	assert(not a or type(a) == 'number', "You must supply a valid number for A!")

	self.r = r and math.round(math.clamp(r, 0, 255)) or 0
	self.g = g and math.round(math.clamp(g, 0, 255)) or 0
	self.b = b and math.round(math.clamp(b, 0, 255)) or 0
	self.a = a and math.round(math.clamp(a, 0, 255)) or 255
end

function Color:__tostring()
	return self.r .. ', ' .. self.g .. ', ' .. self.b .. ', ' .. self.a
end

function Color:__add(addend)
	assert(class.isInstance(addend, Color), "Addend must be a valid Color!")

	return Color(self.r + addend.r, self.g + addend.g, self.b + addend.b, self.a + addend.a)
end

function Color:__sub(subtrahend)
	assert(class.isInstance(subtrahend, Color), "Subtrahend must be a valid Color!")

	return Color(self.r - subtrahend.r, self.g - subtrahend.g, self.b - subtrahend.b, self.a - subtrahend.a)
end

function Color:__mul(factor)
	assert(type(factor) == 'number', "Factor must be a valid number!")

	return Color(self.r * factor, self.g * factor, self.b * factor, self.a * factor)
end

function Color:__div(devisor)
	assert(type(devisor) == 'number', "Devisor must be a valid number!")

	return Color(self.r / devisor, self.g / devisor, self.b / devisor, self.a / devisor)
end

function Color:__eq(comparison)
	if class.isInstance(comparison, Color) then
		return self.r == comparison.r and self.g == comparison.g and self.b == comparison.b and self.a == comparison.a
	end

	return false
end

function Color:values()
	return self.r, self.g, self.b, self.a
end

function Color:copy()
	return Color(self:values())
end

function Color.fromHSV(hue, saturation, value)
	assert(type(hue) == 'number', "You must supply a valid number for Hue!")
	assert(type(saturation) == 'number', "You must supply a valid number for Saturation!")
	assert(type(value) == 'number', "You must supply a valid number for Value!")

	local hue = math.round(hue % 361)
	local saturation = math.clamp(saturation, 0, 1)
	local value = math.clamp(value, 0, 1)

	if saturation == 0 then
		return Color(value, value, value)
	end

	hue = hue / 60

	local i = math.floor(hue)
	local f = hue - i
	local v = math.round(255 * value)
	local p = math.round(255 * value * (1 - saturation))
	local q = math.round(255 * value * (1 - saturation * f))
	local t = math.round(255 * value * (1 - saturation * (1 - f)))

	if i == 0 then
		return Color(v, t, p)
	elseif i == 1 then
		return Color(q, v, p)
	elseif i == 2 then
		return Color(p, v, t)
	elseif i == 3 then
		return Color(p, q, v)
	elseif i == 4 then
		return Color(t, p, v)
	end

	return Color(v, p, q)
end

Color.AliceBlue = Color(240, 248, 255)
Color.AntiqueWhite = Color(250, 235, 215)
Color.Aqua = Color(0, 255, 255)
Color.Aquamarine = Color(127, 255, 212)
Color.Azure = Color(240, 255, 255)
Color.Beige = Color(245, 245, 220)
Color.Bisque = Color(255, 228, 196)
Color.Black = Color(0, 0, 0)
Color.BlanchedAlmond = Color(255, 235, 205)
Color.Blue = Color(0, 0, 255)
Color.BlueViolet = Color(138, 43, 226)
Color.Brown = Color(165, 42, 42)
Color.BurlyWood = Color(222, 184, 135)
Color.CadetBlue = Color(95, 158, 160)
Color.Chartreuse = Color(127, 255, 0)
Color.Chocolate = Color(210, 105, 30)
Color.Coral = Color(255, 127, 80)
Color.CornflowerBlue = Color(100, 149, 237)
Color.Cornsilk = Color(255, 248, 220)
Color.Crimson = Color(220, 20, 60)
Color.Cyan = Color(0, 255, 255)
Color.DarkBlue = Color(0, 0, 139)
Color.DarkCyan = Color(0, 139, 139)
Color.DarkGoldenRod = Color(184, 134, 11)
Color.DarkGray = Color(169, 169, 169)
Color.DarkGreen = Color(0, 100, 0)
Color.DarkKhaki = Color(189, 183, 107)
Color.DarkMagenta = Color(139, 0, 139)
Color.DarkOliveGreen = Color(85, 107, 47)
Color.DarkOrange = Color(255, 140, 0)
Color.DarkOrchid = Color(153, 50, 204)
Color.DarkRed = Color(139, 0, 0)
Color.DarkSalmon = Color(233, 150, 122)
Color.DarkSeaGreen = Color(143, 188, 143)
Color.DarkSlateBlue = Color(72, 61, 139)
Color.DarkSlateGray = Color(47, 79, 79)
Color.DarkTurquoise = Color(0, 206, 209)
Color.DarkViolet = Color(148, 0, 211)
Color.DeepPink = Color(255, 20, 147)
Color.DeepSkyBlue = Color(0, 191, 255)
Color.DimGray = Color(105, 105, 105)
Color.DodgerBlue = Color(30, 144, 255)
Color.FireBrick = Color(178, 34, 34)
Color.FloralWhite = Color(255, 250, 240)
Color.ForestGreen = Color(34, 139, 34)
Color.Fuchsia = Color(255, 0, 255)
Color.Gainsboro = Color(220, 220, 220)
Color.GhostWhite = Color(248, 248, 255)
Color.Gold = Color(255, 215, 0)
Color.GoldenRod = Color(218, 165, 32)
Color.Gray = Color(128, 128, 128)
Color.Green = Color(0, 128, 0)
Color.GreenYellow = Color(173, 255, 47)
Color.HoneyDew = Color(240, 255, 240)
Color.HotPink = Color(255, 105, 180)
Color.IndianRed = Color(205, 92, 92)
Color.Indigo = Color(75, 0, 130)
Color.Ivory = Color(255, 255, 240)
Color.Khaki = Color(240, 230, 140)
Color.Lavender = Color(230, 230, 250)
Color.LavenderBlush = Color(255, 240, 245)
Color.LawnGreen = Color(124, 252, 0)
Color.LemonChiffon = Color(255, 250, 205)
Color.LightBlue = Color(173, 216, 230)
Color.LightCoral = Color(240, 128, 128)
Color.LightCyan = Color(224, 255, 255)
Color.LightGoldenRodYellow = Color(250, 250, 210)
Color.LightGray = Color(211, 211, 211)
Color.LightGreen = Color(144, 238, 144)
Color.LightPink = Color(255, 182, 193)
Color.LightSalmon = Color(255, 160, 122)
Color.LightSeaGreen = Color(32, 178, 170)
Color.LightSkyBlue = Color(135, 206, 250)
Color.LightSlateGray = Color(119, 136, 153)
Color.LightSteelBlue = Color(176, 196, 222)
Color.LightYellow = Color(255, 255, 224)
Color.Lime = Color(0, 255, 0)
Color.LimeGreen = Color(50, 205, 50)
Color.Linen = Color(250, 240, 230)
Color.Magenta = Color(255, 0, 255)
Color.Maroon = Color(128, 0, 0)
Color.MediumAquaMarine = Color(102, 205, 170)
Color.MediumBlue = Color(0, 0, 205)
Color.MediumOrchid = Color(186, 85, 211)
Color.MediumPurple = Color(147, 112, 219)
Color.MediumSeaGreen = Color(60, 179, 113)
Color.MediumSlateBlue = Color(123, 104, 238)
Color.MediumSpringGreen = Color(0, 250, 154)
Color.MediumTurquoise = Color(72, 209, 204)
Color.MediumVioletRed = Color(199, 21, 133)
Color.MidnightBlue = Color(25, 25, 112)
Color.MintCream = Color(245, 255, 250)
Color.MistyRose = Color(255, 228, 225)
Color.Moccasin = Color(255, 228, 181)
Color.NavajoWhite = Color(255, 222, 173)
Color.Navy = Color(0, 0, 128)
Color.OldLace = Color(253, 245, 230)
Color.Olive = Color(128, 128, 0)
Color.OliveDrab = Color(107, 142, 35)
Color.Orange = Color(255, 165, 0)
Color.OrangeRed = Color(255, 69, 0)
Color.Orchid = Color(218, 112, 214)
Color.PaleGoldenRod = Color(238, 232, 170)
Color.PaleGreen = Color(152, 251, 152)
Color.PaleTurquoise = Color(175, 238, 238)
Color.PaleVioletRed = Color(219, 112, 147)
Color.PapayaWhip = Color(255, 239, 213)
Color.PeachPuff = Color(255, 218, 185)
Color.Peru = Color(205, 133, 63)
Color.Pink = Color(255, 192, 203)
Color.Plum = Color(221, 160, 221)
Color.PowderBlue = Color(176, 224, 230)
Color.Purple = Color(128, 0, 128)
Color.Red = Color(255, 0, 0)
Color.RosyBrown = Color(188, 143, 143)
Color.RoyalBlue = Color(65, 105, 225)
Color.SaddleBrown = Color(139, 69, 19)
Color.Salmon = Color(250, 128, 114)
Color.SandyBrown = Color(244, 164, 96)
Color.SeaGreen = Color(46, 139, 87)
Color.SeaShell = Color(255, 245, 238)
Color.Sienna = Color(160, 82, 45)
Color.Silver = Color(192, 192, 192)
Color.SkyBlue = Color(135, 206, 235)
Color.SlateBlue = Color(106, 90, 205)
Color.SlateGray = Color(112, 128, 144)
Color.Snow = Color(255, 250, 250)
Color.SpringGreen = Color(0, 255, 127)
Color.SteelBlue = Color(70, 130, 180)
Color.Tan = Color(210, 180, 140)
Color.Teal = Color(0, 128, 128)
Color.Thistle = Color(216, 191, 216)
Color.Tomato = Color(255, 99, 71)
Color.Transparent = Color(0, 0, 0, 0)
Color.Turquoise = Color(64, 224, 208)
Color.Violet = Color(238, 130, 238)
Color.Wheat = Color(245, 222, 179)
Color.White = Color(255, 255, 255)
Color.WhiteSmoke = Color(245, 245, 245)
Color.Yellow = Color(255, 255, 0)
Color.YellowGreen = Color(154, 205, 50)
