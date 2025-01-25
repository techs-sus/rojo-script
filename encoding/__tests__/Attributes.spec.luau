local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local scriptWithAttributes = require(ServerScriptService.Decoder.testRbxms.scriptWithAttributes)

--[[
Variants in this test:
String
Bool,
Float32/Float64/Number,
UDim/UDim2,
BrickColor,
Color3,
Vector2/Vector3,
CFrame,
NumberRange,
Rect,
Font
]]

local EXPECTED_ITEMS = table.freeze({
	foo = "bar",
	bar = true,
	baz = false,
	bud = 777,
	blud = UDim.new(777, 777),
	blud2 = UDim2.new(777, 777, 777, 777),
	bc0 = BrickColor.new("Medium stone grey"),
	color0 = Color3.fromRGB(777, 777, 777),
	vector2 = Vector2.one * 777,
	vector3 = Vector3.one * 777,
	cframe = CFrame.new(777, 777, 777),
	range = NumberRange.new(0, 0.5),
	rect = Rect.new(777, 777, 777, 777),
	font = Font.fromName("SourceSansPro", Enum.FontWeight.Bold, Enum.FontStyle.Italic),
})

local test = JestGlobals.test
local expect = JestGlobals.expect

test("ensure Attributes are decoded correctly", function(_, done)
	local root = Decoder(scriptWithAttributes)
	local script: Script = root:FindFirstChildWhichIsA("Script")

	expect(script).toEqual(expect.anything())
	expect(script:GetAttributes()).toMatchObject(EXPECTED_ITEMS)

	done()
end)
