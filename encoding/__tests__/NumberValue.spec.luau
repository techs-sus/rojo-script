local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local sentinelNumberValue = require(ServerScriptService.Decoder.testRbxms.sentinelNumberValue)

local test = JestGlobals.test
local expectedValueHelper = require(script.Parent.expectedValueHelper)(JestGlobals.expect)

test(
	"ensure NumberValue [value = 777.777] is decoded correctly",
	expectedValueHelper(sentinelNumberValue, "NumberValue", 777.777)
)
