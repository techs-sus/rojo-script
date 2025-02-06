local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local sentinelVector3Value = require(ServerScriptService.Decoder.testRbxms.sentinelVector3Value)

local test = JestGlobals.test
local expectedValueHelper = require(script.Parent.expectedValueHelper)(JestGlobals.expect)

test(
	"ensure Vector3Value [value = Vector3.one * 777] is decoded correctly",
	expectedValueHelper(sentinelVector3Value, "Vector3Value", Vector3.one * 777)
)
