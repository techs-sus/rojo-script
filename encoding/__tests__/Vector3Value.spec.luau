local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local sentinelVector3Value = require(ServerScriptService.Decoder.testRbxms.sentinelVector3Value)

local test = JestGlobals.test
local expect = JestGlobals.expect

test("ensure Vector3Value [value = Vector3.one * 777] is decoded correctly", function(_, done)
	local root = Decoder(sentinelVector3Value)
	expect(root:FindFirstChildWhichIsA("Vector3Value").Value).toBe(Vector3.one * 777)

	done()
end)
