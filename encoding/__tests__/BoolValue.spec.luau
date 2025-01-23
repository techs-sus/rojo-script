local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local boolValueTrue = require(ServerScriptService.Decoder.testRbxms.boolValueTrue)
local boolValueFalse = require(ServerScriptService.Decoder.testRbxms.boolValueFalse)

local test = JestGlobals.test
local expect = JestGlobals.expect

test("ensure boolValue [value = false] is decoded correctly", function(_, done)
	local root = Decoder(boolValueFalse)
	expect(root:FindFirstChildWhichIsA("BoolValue").Value).toBe(false)

	done()
end)

test("ensure boolValue [value = true] is decoded correctly", function(_, done)
	local root = Decoder(boolValueTrue)
	expect(root:FindFirstChildWhichIsA("BoolValue").Value).toBe(true)

	done()
end)
