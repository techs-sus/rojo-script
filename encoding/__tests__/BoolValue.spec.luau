local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local boolValueTrue = require(ServerScriptService.Decoder.testRbxms.boolValueTrue)
local boolValueFalse = require(ServerScriptService.Decoder.testRbxms.boolValueFalse)

local test = JestGlobals.test
local expectedValueHelper = require(script.Parent.expectedValueHelper)(JestGlobals.expect)

test("ensure BoolValue [value = false] is decoded correctly", expectedValueHelper(boolValueFalse, "BoolValue", false))
test("ensure BoolValue [value = true] is decoded correctly", expectedValueHelper(boolValueTrue, "BoolValue", true))
