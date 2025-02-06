local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local scriptTaggedWithAllLuaKeywords = require(ServerScriptService.Decoder.testRbxms.scriptTaggedWithAllLuaKeywords)

local EXPECTED_ITEMS = table.freeze({
	"and",
	"break",
	"do",
	"else",
	"elseif",
	"end",
	"false",
	"for",
	"function",
	"if",
	"in",
	"local",
	"nil",
	"not",
	"or",
	"repeat",
	"return",
	"then",
	"true",
	"until",
	"while",
})

local test = JestGlobals.test
local expect = JestGlobals.expect

test("ensure Tags are decoded correctly", function(_, done)
	local root = Decoder(scriptTaggedWithAllLuaKeywords)
	expect(root).toEqual(expect.anything())

	local script: Script = root:FindFirstChildWhichIsA("Script")

	expect(script).toEqual(expect.anything())
	expect(script:GetTags()).toEqual(expect.arrayContaining(EXPECTED_ITEMS))

	done()
end)
