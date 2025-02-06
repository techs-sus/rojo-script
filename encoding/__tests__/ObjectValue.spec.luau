local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local deeplyNestedObjectValue = require(ServerScriptService.Decoder.testRbxms.deeplyNestedObjectValue)

local test = JestGlobals.test
local expect = JestGlobals.expect

test("ensure a deeply nested ObjectValue is decoded correctly", function(_, done)
	local root = Decoder(deeplyNestedObjectValue)
	expect(root).toEqual(expect.anything())

	local rootObjectValue = root:FindFirstChildWhichIsA("ObjectValue")
	expect(rootObjectValue).toEqual(expect.anything())
	expect(rootObjectValue.ClassName).toEqual("ObjectValue")

	local nestedObjectValue = rootObjectValue:FindFirstChildWhichIsA("ObjectValue")
	expect(nestedObjectValue).toEqual(expect.anything())
	expect(nestedObjectValue.ClassName).toEqual("ObjectValue")

	local nestedScript = rootObjectValue:FindFirstChildWhichIsA("Script")

	expect(nestedScript).toEqual(expect.anything())
	expect(nestedScript.ClassName).toEqual("Script")

	expect(rootObjectValue.Value).toBe(nestedObjectValue)
	expect(nestedObjectValue.Value).toBe(nestedScript)

	done()
end)
