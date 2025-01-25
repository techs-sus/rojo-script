local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local exampleCustomPhysicalProperties = require(ServerScriptService.Decoder.testRbxms.exampleCustomPhysicalProperties)

local test = JestGlobals.test
local expect = JestGlobals.expect

test("ensure CustomPhysicalProperties [value = <example>] is decoded correctly", function(_, done)
	local root = Decoder(exampleCustomPhysicalProperties)
	expect(root:FindFirstChildWhichIsA("Part").CustomPhysicalProperties).toBe(PhysicalProperties.new(1, 2, 0.5, 4, 5))

	done()
end)
