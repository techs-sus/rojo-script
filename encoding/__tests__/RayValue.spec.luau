local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local sentinelRayValue = require(ServerScriptService.Decoder.testRbxms.sentinelRayValue)

local test = JestGlobals.test
local expectedValueHelper = require(script.Parent.expectedValueHelper)(JestGlobals.expect)

test(
	"ensure RayValue [value = <sentinel>] is decoded correctly",
	expectedValueHelper(sentinelRayValue, "RayValue", Ray.new(Vector3.one * 777, Vector3.one * 777))
)
