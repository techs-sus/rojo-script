local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local sentinelRayValue = require(ServerScriptService.Decoder.testRbxms.sentinelRayValue)

local test = JestGlobals.test
local expect = JestGlobals.expect

test("ensure RayValue [value = <sentinel>] is decoded correctly", function(_, done)
	local root = Decoder(sentinelRayValue)
	expect(root:FindFirstChildWhichIsA("RayValue").Value).toBe(Ray.new(Vector3.one * 777, Vector3.one * 777))

	done()
end)
