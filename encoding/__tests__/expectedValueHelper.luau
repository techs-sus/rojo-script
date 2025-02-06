local ServerScriptService = game:GetService("ServerScriptService")
local Decoder = require(ServerScriptService.Decoder.decoder)

return function(expect)
	return function(payload: buffer, expectedClassName: string, expectedValue: any)
		return function(_, done)
			local root = Decoder(payload)
			expect(root).toEqual(expect.anything())
			expect(typeof(root)).toEqual("Instance")

			local value = root:FindFirstChildWhichIsA(expectedClassName)
			expect(value).toEqual(expect.anything())
			expect(value.ClassName).toEqual(expectedClassName)
			expect(value.Value).toBe(expectedValue)

			done()
		end
	end
end
