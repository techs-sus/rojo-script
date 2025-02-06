local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local limeGreenBrickColorValue = require(ServerScriptService.Decoder.testRbxms.limeGreenBrickColorValue)

local test = JestGlobals.test
local expectedValueHelper = require(script.Parent.expectedValueHelper)(JestGlobals.expect)

test(
	'ensure BrickColorValue [value = BrickColor.new("Lime green")] is decoded correctly',
	expectedValueHelper(limeGreenBrickColorValue, "BrickColorValue", BrickColor.new("Lime green"))
)
