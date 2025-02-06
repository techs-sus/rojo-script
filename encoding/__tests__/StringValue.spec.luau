local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local helloWorldStringValue = require(ServerScriptService.Decoder.testRbxms.helloWorldStringValue)

local test = JestGlobals.test
local expectedValueHelper = require(script.Parent.expectedValueHelper)(JestGlobals.expect)

test(
	'ensure StringValue [value = "hello, world!"] is decoded correctly',
	expectedValueHelper(helloWorldStringValue, "StringValue", "hello, world!")
)
