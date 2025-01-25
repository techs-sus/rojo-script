local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local allPossibleFacesValues = require(ServerScriptService.Decoder.testRbxms.allPossibleFacesValues)

type State = {
	Right: boolean,
	Top: boolean,
	Back: boolean,
	Left: boolean,
	Bottom: boolean,
	Front: boolean,
}

local handlesNameToExpectedState: { [string]: State } = table.freeze(
	HttpService:JSONDecode(
		[[{"100011":{"Top":true,"Front":true,"Bottom":false,"Right":true,"Left":false,"Back":false},"111010":{"Top":true,"Front":true,"Bottom":true,"Right":false,"Left":true,"Back":false},"010010":{"Top":true,"Front":false,"Bottom":true,"Right":false,"Left":false,"Back":false},"000011":{"Top":true,"Front":false,"Bottom":false,"Right":true,"Left":false,"Back":false},"010100":{"Top":false,"Front":false,"Bottom":true,"Right":false,"Left":false,"Back":true},"100100":{"Top":false,"Front":true,"Bottom":false,"Right":false,"Left":false,"Back":true},"000100":{"Top":false,"Front":false,"Bottom":false,"Right":false,"Left":false,"Back":true},"100001":{"Top":false,"Front":true,"Bottom":false,"Right":true,"Left":false,"Back":false},"000001":{"Top":false,"Front":false,"Bottom":false,"Right":true,"Left":false,"Back":false},"010101":{"Top":false,"Front":false,"Bottom":true,"Right":true,"Left":false,"Back":true},"000110":{"Top":true,"Front":false,"Bottom":false,"Right":false,"Left":false,"Back":true},"100110":{"Top":true,"Front":true,"Bottom":false,"Right":false,"Left":false,"Back":true},"111011":{"Top":true,"Front":true,"Bottom":true,"Right":true,"Left":true,"Back":false},"011011":{"Top":true,"Front":false,"Bottom":true,"Right":true,"Left":true,"Back":false},"010000":{"Top":false,"Front":false,"Bottom":true,"Right":false,"Left":false,"Back":false},"011010":{"Top":true,"Front":false,"Bottom":true,"Right":false,"Left":true,"Back":false},"001101":{"Top":false,"Front":false,"Bottom":false,"Right":true,"Left":true,"Back":true},"101101":{"Top":false,"Front":true,"Bottom":false,"Right":true,"Left":true,"Back":true},"011110":{"Top":true,"Front":false,"Bottom":true,"Right":false,"Left":true,"Back":true},"111110":{"Top":true,"Front":true,"Bottom":true,"Right":false,"Left":true,"Back":true},"011000":{"Top":false,"Front":false,"Bottom":true,"Right":false,"Left":true,"Back":false},"111000":{"Top":false,"Front":true,"Bottom":true,"Right":false,"Left":true,"Back":false},"011001":{"Top":false,"Front":false,"Bottom":true,"Right":true,"Left":true,"Back":false},"111001":{"Top":false,"Front":true,"Bottom":true,"Right":true,"Left":true,"Back":false},"011101":{"Top":false,"Front":false,"Bottom":true,"Right":true,"Left":true,"Back":true},"101111":{"Top":true,"Front":true,"Bottom":false,"Right":true,"Left":true,"Back":true},"001010":{"Top":true,"Front":false,"Bottom":false,"Right":false,"Left":true,"Back":false},"100111":{"Top":true,"Front":true,"Bottom":false,"Right":true,"Left":false,"Back":true},"000111":{"Top":true,"Front":false,"Bottom":false,"Right":true,"Left":false,"Back":true},"110101":{"Top":false,"Front":true,"Bottom":true,"Right":true,"Left":false,"Back":true},"110000":{"Top":false,"Front":true,"Bottom":true,"Right":false,"Left":false,"Back":false},"000101":{"Top":false,"Front":false,"Bottom":false,"Right":true,"Left":false,"Back":true},"010011":{"Top":true,"Front":false,"Bottom":true,"Right":true,"Left":false,"Back":false},"000010":{"Top":true,"Front":false,"Bottom":false,"Right":false,"Left":false,"Back":false},"101011":{"Top":true,"Front":true,"Bottom":false,"Right":true,"Left":true,"Back":false},"110011":{"Top":true,"Front":true,"Bottom":true,"Right":true,"Left":false,"Back":false},"100000":{"Top":false,"Front":true,"Bottom":false,"Right":false,"Left":false,"Back":false},"100010":{"Top":true,"Front":true,"Bottom":false,"Right":false,"Left":false,"Back":false},"100101":{"Top":false,"Front":true,"Bottom":false,"Right":true,"Left":false,"Back":true},"010001":{"Top":false,"Front":false,"Bottom":true,"Right":true,"Left":false,"Back":false},"110110":{"Top":true,"Front":true,"Bottom":true,"Right":false,"Left":false,"Back":true},"010110":{"Top":true,"Front":false,"Bottom":true,"Right":false,"Left":false,"Back":true},"001000":{"Top":false,"Front":false,"Bottom":false,"Right":false,"Left":true,"Back":false},"101110":{"Top":true,"Front":true,"Bottom":false,"Right":false,"Left":true,"Back":true},"001011":{"Top":true,"Front":false,"Bottom":false,"Right":true,"Left":true,"Back":false},"101000":{"Top":false,"Front":true,"Bottom":false,"Right":false,"Left":true,"Back":false},"101100":{"Top":false,"Front":true,"Bottom":false,"Right":false,"Left":true,"Back":true},"110001":{"Top":false,"Front":true,"Bottom":true,"Right":true,"Left":false,"Back":false},"111101":{"Top":false,"Front":true,"Bottom":true,"Right":true,"Left":true,"Back":true},"001110":{"Top":true,"Front":false,"Bottom":false,"Right":false,"Left":true,"Back":true},"011111":{"Top":true,"Front":false,"Bottom":true,"Right":true,"Left":true,"Back":true},"111111":{"Top":true,"Front":true,"Bottom":true,"Right":true,"Left":true,"Back":true},"001100":{"Top":false,"Front":false,"Bottom":false,"Right":false,"Left":true,"Back":true},"101010":{"Top":true,"Front":true,"Bottom":false,"Right":false,"Left":true,"Back":false},"101001":{"Top":false,"Front":true,"Bottom":false,"Right":true,"Left":true,"Back":false},"001001":{"Top":false,"Front":false,"Bottom":false,"Right":true,"Left":true,"Back":false},"110111":{"Top":true,"Front":true,"Bottom":true,"Right":true,"Left":false,"Back":true},"000000":{"Top":false,"Front":false,"Bottom":false,"Right":false,"Left":false,"Back":false},"110010":{"Top":true,"Front":true,"Bottom":true,"Right":false,"Left":false,"Back":false},"110100":{"Top":false,"Front":true,"Bottom":true,"Right":false,"Left":false,"Back":true},"011100":{"Top":false,"Front":false,"Bottom":true,"Right":false,"Left":true,"Back":true},"111100":{"Top":false,"Front":true,"Bottom":true,"Right":false,"Left":true,"Back":true},"001111":{"Top":true,"Front":false,"Bottom":false,"Right":true,"Left":true,"Back":true},"010111":{"Top":true,"Front":false,"Bottom":true,"Right":true,"Left":false,"Back":true}}]]
	)
)

local test = JestGlobals.test
local expect = JestGlobals.expect

local root = Decoder(allPossibleFacesValues)
local rootFolder: Folder = root:FindFirstChildWhichIsA("Folder")

for instanceName, expectedState in handlesNameToExpectedState do
	test(`ensure possible Faces value [{instanceName}] is decoded correctly`, function(_, done)
		expect(rootFolder).toEqual(expect.anything())
		local instance = rootFolder:FindFirstChild(instanceName)
		expect(instance).toEqual(expect.anything())
		expect(instance.ClassName).toBe("Handles")

		local state = {
			Right = instance.Faces.Right,
			Top = instance.Faces.Top,
			Back = instance.Faces.Back,
			Left = instance.Faces.Left,
			Bottom = instance.Faces.Bottom,
			Front = instance.Faces.Front,
		}

		expect(state).toMatchObject(expectedState)

		done()
	end)
end
