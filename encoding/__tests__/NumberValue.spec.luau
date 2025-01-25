local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local sentinelNumberValue = require(ServerScriptService.Decoder.testRbxms.sentinelNumberValue)

local test = JestGlobals.test
local expect = JestGlobals.expect

test("ensure NumberValue [value = 777.777] is decoded correctly", function(_, done)
	local root = Decoder(sentinelNumberValue)
	expect(root:FindFirstChildWhichIsA("NumberValue").Value).toBe(777.777)

	done()
end)
