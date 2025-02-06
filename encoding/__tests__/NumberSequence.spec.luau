local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local exampleTrail = require(ServerScriptService.Decoder.testRbxms.exampleTrail)

local test = JestGlobals.test
local expect = JestGlobals.expect

test("ensure NumberSequence [via Trail, value = <example>] is decoded correctly", function(_, done)
	local root = Decoder(exampleTrail)
	expect(root).toEqual(expect.anything())

	local trail = root:FindFirstChildWhichIsA("Trail")
	expect(trail).toEqual(expect.anything())
	expect(trail.ClassName).toEqual("Trail")

	expect(trail.Transparency).toBe(NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1, 0),
		NumberSequenceKeypoint.new(0.1, 0.1, 0),
		NumberSequenceKeypoint.new(0.2, 0.1, 0),
		NumberSequenceKeypoint.new(1, 0.1, 0),
	}))

	done()
end)
