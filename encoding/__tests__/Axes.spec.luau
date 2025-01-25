local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local allPossibleAxesValues = require(ServerScriptService.Decoder.testRbxms.allPossibleAxesValues)

local EXPECTED_STATES = table.freeze({
	["X+Y+Z"] = { X = true, Y = true, Z = true },
	["X"] = { X = true, Y = false, Z = false },
	["X+Y"] = { X = true, Y = true, Z = false },
	["Y"] = { X = false, Y = true, Z = false },
	["Y+Z"] = { X = false, Y = true, Z = true },
	["Z"] = { X = false, Y = false, Z = true },
})

local test = JestGlobals.test
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local root = Decoder(allPossibleAxesValues)
local rootFolder: Folder = root:FindFirstChildWhichIsA("Folder")

for instanceName, expectedState in EXPECTED_STATES do
	test(`ensure possible Axes value [{instanceName}] is decoded correctly`, function(_, done)
		expect(rootFolder).toEqual(expect.anything())
		local instance = rootFolder:FindFirstChild(instanceName)
		expect(instance).toEqual(expect.anything())
		expect(instance.ClassName).toBe("ArcHandles")

		local state = { X = instance.Axes.X, Y = instance.Axes.Y, Z = instance.Axes.Z }
		expect(state).toMatchObject(expectedState)

		done()
	end)
end
