local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local helloWorldStringValue = require(ServerScriptService.Decoder.testRbxms.helloWorldStringValue)

local test = JestGlobals.test
local expect = JestGlobals.expect

test('ensure StringValue [value = "hello, world!"] is decoded correctly', function(_, done)
	local root = Decoder(helloWorldStringValue)
	expect(root:FindFirstChildWhichIsA("StringValue").Value).toBe("hello, world!")

	done()
end)
