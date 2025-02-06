local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local sentinelIntValue = require(ServerScriptService.Decoder.testRbxms.sentinelIntValue)

local test = JestGlobals.test
local expectedValueHelper = require(script.Parent.expectedValueHelper)(JestGlobals.expect)

test("ensure IntValue [value = 777] is decoded correctly", expectedValueHelper(sentinelIntValue, "IntValue", 777))
