local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ServerScriptService.DevPackages.JestGlobals)
local Decoder = require(ServerScriptService.Decoder.decoder)

local cframeValue = require(ServerScriptService.Decoder.testRbxms.cframeValue)

local test = JestGlobals.test
local expectedValueHelper = require(script.Parent.expectedValueHelper)(JestGlobals.expect)

test(
	"ensure CFrameValue [value = <complex>] is decoded correctly",
	expectedValueHelper(cframeValue, "CFrameValue", CFrame.new(777, 777, 777) * CFrame.Angles(23, 25, 23))
)
