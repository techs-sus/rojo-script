local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local all3sColor3Value = require(ServerScriptService.Decoder.testRbxms.all3sColor3Value)

local test = JestGlobals.test
local expectedValueHelper = require(script.Parent.expectedValueHelper)(JestGlobals.expect)

test(
	"ensure Color3Value [value = Color3.fromRGB(333, 333, 333)] is decoded correctly",
	expectedValueHelper(all3sColor3Value, "Color3Value", Color3.fromRGB(333, 333, 333))
)
