local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local all3sColor3Value = require(ServerScriptService.Decoder.testRbxms.all3sColor3Value)

local test = JestGlobals.test
local expect = JestGlobals.expect

test("ensure Color3Value [value = Color3.fromRGB(333, 333, 333)] is decoded correctly", function(_, done)
	local root = Decoder(all3sColor3Value)
	expect(root:FindFirstChildWhichIsA("Color3Value").Value).toBe(Color3.fromRGB(333, 333, 333))

	done()
end)
