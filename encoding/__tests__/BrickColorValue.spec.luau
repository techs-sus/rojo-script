local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local limeGreenBrickColorValue = require(ServerScriptService.Decoder.testRbxms.limeGreenBrickColorValue)

local test = JestGlobals.test
local expect = JestGlobals.expect

test('ensure BrickColorValue [value = BrickColor.new("Lime green")] is decoded correctly', function(_, done)
	local root = Decoder(limeGreenBrickColorValue)
	expect(root:FindFirstChildWhichIsA("BrickColorValue").Value).toBe(BrickColor.new("Lime green"))

	done()
end)
