local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local exampleTrail = require(ServerScriptService.Decoder.testRbxms.exampleTrail)

local test = JestGlobals.test
local expect = JestGlobals.expect

test("ensure ColorSequence [via Trail, value = <example>] is decoded correctly", function(_, done)
	local root = Decoder(exampleTrail)
	expect(root).toEqual(expect.anything())

	local trail = root:FindFirstChildWhichIsA("Trail")
	expect(trail).toEqual(expect.anything())
	expect(trail.ClassName).toEqual("Trail")
	expect(trail.Color).toBe(ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
		ColorSequenceKeypoint.new(0.1, Color3.new(0, 0, 0)),
		ColorSequenceKeypoint.new(0.2, Color3.fromRGB(1, 2, 3)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
	}))

	done()
end)
