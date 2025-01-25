local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local cframeValue = require(ServerScriptService.Decoder.testRbxms.cframeValue)

local test = JestGlobals.test
local expect = JestGlobals.expect

test("ensure CFrameValue [value = <complex>] is decoded correctly", function(_, done)
	local root = Decoder(cframeValue)
	expect(root:FindFirstChildWhichIsA("CFrameValue").Value).toBe(CFrame.new(777, 777, 777) * CFrame.Angles(23, 25, 23))

	done()
end)
