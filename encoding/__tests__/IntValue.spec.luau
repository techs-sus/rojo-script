local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local sentinelIntValue = require(ServerScriptService.Decoder.testRbxms.sentinelIntValue)

local test = JestGlobals.test
local expect = JestGlobals.expect

test("ensure IntValue [value = 777] is decoded correctly", function(_, done)
	local root = Decoder(sentinelIntValue)
	expect(root:FindFirstChildWhichIsA("IntValue").Value).toBe(777)

	done()
end)
