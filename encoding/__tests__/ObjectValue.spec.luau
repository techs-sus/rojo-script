local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local deeplyNestedObjectValue = require(ServerScriptService.Decoder.testRbxms.deeplyNestedObjectValue)

local test = JestGlobals.test
local expect = JestGlobals.expect

test("ensure a deeply nested ObjectValue is decoded correctly", function(_, done)
	local root = Decoder(deeplyNestedObjectValue)
	local rootObjectValue = root:FindFirstChildWhichIsA("ObjectValue")
	expect(rootObjectValue.Value).toBe(rootObjectValue:FindFirstChildWhichIsA("ObjectValue"))
	expect(rootObjectValue:FindFirstChildWhichIsA("ObjectValue").Value).toBe(
		rootObjectValue:FindFirstChildWhichIsA("Script")
	)

	done()
end)
