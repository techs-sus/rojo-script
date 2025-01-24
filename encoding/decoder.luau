--!native
--!optimize 2

-- TODO: Actually parse output from generator.rs

local TYPE_ID = table.freeze({
	String = 0,
	Attributes = 1,
	Axes = 2,
	Bool = 3,
	BrickColor = 4,
	CFrame = 5,
	Color3 = 6,
	Color3uint8 = 7,
	ColorSequence = 8,
	Enum = 9,
	Faces = 10,
	Float32 = 11,
	Float64 = 12,
	Int32 = 13,
	MaterialColors = 14,
	NumberRange = 15,
	NumberSequence = 16,
	None = 17,
	DefaultPhysicalProperties = 18,
	CustomPhysicalProperties = 19,
	Ray = 20,
	Rect = 21,
	Ref = 22,
	Region3 = 23,
	Region3int16 = 24,
	SecurityCapabilities = 25,
	BinaryString = 26,
	Tags = 27,
	UDim = 28,
	UDim2 = 29,
	Vector2 = 30,
	Vector2int16 = 31,
	Vector3 = 32,
	Vector3int16 = 33,

	Font = 34,
})

-- thank you rojo developers: https://dom.rojo.space/binary.html#cframe (god bless)
local CFRAME_ID_LOOKUP_TABLE = table.freeze({
	[0x02] = CFrame.fromEulerAnglesYXZ(0, 0, 0),
	[0x03] = CFrame.fromEulerAnglesYXZ(math.rad(90), 0, 0),
	[0x05] = CFrame.fromEulerAnglesYXZ(0, math.rad(180), math.rad(180)),
	[0x06] = CFrame.fromEulerAnglesYXZ(math.rad(-90), 0, 0),
	[0x07] = CFrame.fromEulerAnglesYXZ(0, math.rad(180), math.rad(90)),
	[0x09] = CFrame.fromEulerAnglesYXZ(0, math.rad(90), math.rad(90)),
	[0x0a] = CFrame.fromEulerAnglesYXZ(0, 0, math.rad(90)),
	[0x0c] = CFrame.fromEulerAnglesYXZ(0, math.rad(-90), math.rad(90)),
	[0x0d] = CFrame.fromEulerAnglesYXZ(math.rad(-90), math.rad(-90), 0),
	[0x0e] = CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(-90), 0),
	[0x10] = CFrame.fromEulerAnglesYXZ(math.rad(90), math.rad(-90), 0),
	[0x11] = CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(90), 180),

	[0x14] = CFrame.fromEulerAnglesYXZ(0, math.rad(180), 0),
	[0x15] = CFrame.fromEulerAnglesYXZ(math.rad(-90), math.rad(-180), 0),
	[0x17] = CFrame.fromEulerAnglesYXZ(0, 0, math.rad(180)),
	[0x18] = CFrame.fromEulerAnglesYXZ(math.rad(90), math.rad(180), 0),
	[0x19] = CFrame.fromEulerAnglesYXZ(0, 0, math.rad(-90)),
	[0x1b] = CFrame.fromEulerAnglesYXZ(0, math.rad(-90), math.rad(-90)),
	[0x1c] = CFrame.fromEulerAnglesYXZ(0, math.rad(-180), math.rad(-90)),
	[0x1e] = CFrame.fromEulerAnglesYXZ(0, math.rad(90), math.rad(-90)),
	[0x1f] = CFrame.fromEulerAnglesYXZ(math.rad(90), math.rad(90), 0),
	[0x20] = CFrame.fromEulerAnglesYXZ(0, math.rad(90), 0),
	[0x22] = CFrame.fromEulerAnglesYXZ(math.rad(-90), math.rad(90), 0),
	[0x23] = CFrame.fromEulerAnglesYXZ(0, math.rad(-90), math.rad(180)),
})

local NewScript: (code: string, parent: Instance?) -> Script = NewScript
	or function(code, parent)
		local script = Instance.new("Script")
		script.Source = code
		script.Parent = parent

		return script
	end

local NewLocalScript: (code: string, parent: Instance?) -> LocalScript = NewLocalScript
	or function(code, parent)
		local script = Instance.new("LocalScript")
		script.Source = code
		script.Parent = parent

		return script
	end

local NewModuleScript: (code: string, parent: Instance?) -> ModuleScript = NewModuleScript
	or function(code, parent)
		local script = Instance.new("ModuleScript")
		script.Source = code
		script.Parent = parent

		return script
	end

local nilParentedInstance = Instance.new("Folder", nil)

local function decode(payloadBuffer: buffer)
	if nilParentedInstance.Parent ~= nil then
		pcall(game.Destroy, nilParentedInstance)
		nilParentedInstance = Instance.new("Folder", nil)
	end

	local loc = 0
	local VARIANT_DECODER: { [number]: () -> any }
	local nextVariant

	VARIANT_DECODER = table.freeze({
		[TYPE_ID.String] = function()
			local varstringMetadata = buffer.readu8(payloadBuffer, loc)
			loc += 1
			local stringLength

			if varstringMetadata == 1 then
				-- u8
				stringLength = buffer.readu8(payloadBuffer, loc)
				loc += 1
			elseif varstringMetadata == 2 then
				-- u16
				stringLength = buffer.readu16(payloadBuffer, loc)
				loc += 2
			elseif varstringMetadata == 4 then
				-- u32
				stringLength = buffer.readu32(payloadBuffer, loc)
				loc += 4
			elseif varstringMetadata == 8 then
				error("u64 varstring is unsupported")
			elseif varstringMetadata == 16 then
				error("u128 varstring is unsupported")
			else
				error(`varstringMetadata value ({varstringMetadata}) is unsupported`)
			end

			loc += stringLength

			return buffer.readstring(payloadBuffer, loc - stringLength, stringLength)
		end,

		[TYPE_ID.None] = function()
			return nil
		end,

		[TYPE_ID.Ref] = function()
			return VARIANT_DECODER[TYPE_ID.String]()
		end,

		-- [TYPE_ID.Tags] = function(buf: buffer) end,
		[TYPE_ID.Enum] = function()
			local enumInternal = buffer.readu32(payloadBuffer, loc)
			loc += 4
			return enumInternal
		end,

		[TYPE_ID.Float32] = function()
			local float = buffer.readf32(payloadBuffer, loc)
			loc += 4
			return float
		end,

		[TYPE_ID.Float64] = function()
			local float = buffer.readf64(payloadBuffer, loc)
			loc += 8
			return float
		end,

		[TYPE_ID.Int32] = function()
			local int = buffer.readi32(payloadBuffer, loc)
			loc += 4
			return int
		end,

		[TYPE_ID.Bool] = function()
			local bool = buffer.readu8(payloadBuffer, loc)
			loc += 1
			return bool == 1
		end,

		[TYPE_ID.Tags] = function()
			-- length of encoded array
			local tagsLength = buffer.readu16(payloadBuffer, loc)
			loc += 2

			local tags = {}

			while tagsLength > 0 do
				local start = loc
				while true do
					loc += 1
					if buffer.readu8(payloadBuffer, loc) == 0 then
						-- ensure we skip null byte
						loc += 1
						break
					end
				end

				-- ensure we skip null byte in decoded tag
				local tag = buffer.readstring(payloadBuffer, start, loc - start - 1)
				table.insert(tags, tag)

				tagsLength -= 1
			end

			return tags
		end,

		[TYPE_ID.Attributes] = function()
			local attributesLength = buffer.readu16(payloadBuffer, loc)
			loc += 2

			local attributeMap: { [string]: any } = {}
			while attributesLength > 0 do
				local start = loc
				while true do
					loc += 1
					if buffer.readu8(payloadBuffer, loc) == 0 then
						-- ensure we skip null byte
						loc += 1
						break
					end
				end

				-- ensure null byte is skipped in attributeName
				local attributeName = buffer.readstring(payloadBuffer, start, loc - start - 1)

				attributeMap[attributeName] = nextVariant()
				-- print(attributesLength)
				-- print("attribute name", attributeName, attributeMap[attributeName])

				attributesLength -= 1
			end

			return attributeMap
		end,

		[TYPE_ID.SecurityCapabilities] = function()
			-- skip
			loc += 8
		end,

		[TYPE_ID.BrickColor] = function()
			return BrickColor.new(VARIANT_DECODER[TYPE_ID.String]())
		end,

		[TYPE_ID.UDim] = function()
			local offset, scale = buffer.readi32(payloadBuffer, loc), buffer.readf32(payloadBuffer, loc + 4)
			loc += 8

			return UDim.new(scale, offset)
		end,

		[TYPE_ID.UDim2] = function()
			local xOffset, yOffset, xScale, yScale =
				buffer.readi32(payloadBuffer, loc),
				buffer.readi32(payloadBuffer, loc + 4),
				buffer.readf32(payloadBuffer, loc + 8),
				buffer.readf32(payloadBuffer, loc + 12)

			loc += 16

			return UDim2.new(xScale, xOffset, yScale, yOffset)
		end,

		[TYPE_ID.Vector2] = function()
			local x, y = buffer.readf32(payloadBuffer, loc), buffer.readf32(payloadBuffer, loc + 4)
			loc += 8

			return Vector2.new(x, y)
		end,

		[TYPE_ID.Vector2int16] = function()
			local x, y = buffer.readi16(payloadBuffer, loc), buffer.readi16(payloadBuffer, loc + 2)
			loc += 4

			return Vector2int16.new(x, y)
		end,

		[TYPE_ID.Vector3] = function()
			local x, y, z =
				buffer.readf32(payloadBuffer, loc),
				buffer.readf32(payloadBuffer, loc + 4),
				buffer.readf32(payloadBuffer, loc + 8)
			loc += 12

			return Vector3.new(x, y, z)
		end,

		[TYPE_ID.Vector3int16] = function()
			local x, y, z =
				buffer.readi16(payloadBuffer, loc),
				buffer.readi16(payloadBuffer, loc + 2),
				buffer.readi16(payloadBuffer, loc + 4)
			loc += 6

			return Vector3int16.new(x, y, z)
		end,

		[TYPE_ID.CFrame] = function()
			local id = buffer.readu8(payloadBuffer, loc)
			loc += 1

			if id == 0 then
				-- all data is encoded
				local xx, xy, xz, yx, yy, yz, zx, zy, zz, positionX, positionY, positionZ =
					buffer.readf32(payloadBuffer, loc),
					buffer.readf32(payloadBuffer, loc + 4),
					buffer.readf32(payloadBuffer, loc + 8),
					buffer.readf32(payloadBuffer, loc + 12),
					buffer.readf32(payloadBuffer, loc + 16),
					buffer.readf32(payloadBuffer, loc + 20),
					buffer.readf32(payloadBuffer, loc + 24),
					buffer.readf32(payloadBuffer, loc + 28),
					buffer.readf32(payloadBuffer, loc + 32),
					buffer.readf32(payloadBuffer, loc + 36),
					buffer.readf32(payloadBuffer, loc + 40),
					buffer.readf32(payloadBuffer, loc + 44)

				loc += 48

				return CFrame.new(positionX, positionY, positionZ, xx, xy, xz, yx, yy, yz, zx, zy, zz)
			else
				local positionX, positionY, positionZ =
					buffer.readf32(payloadBuffer, loc),
					buffer.readf32(payloadBuffer, loc + 4),
					buffer.readf32(payloadBuffer, loc + 8)
				loc += 12

				return CFrame.new(positionX, positionY, positionZ) * CFRAME_ID_LOOKUP_TABLE[id]
			end
		end,

		[TYPE_ID.Color3] = function()
			local r, g, b =
				buffer.readf32(payloadBuffer, loc),
				buffer.readf32(payloadBuffer, loc + 4),
				buffer.readf32(payloadBuffer, loc + 8)

			loc += 12
			return Color3.new(r, g, b)
		end,

		[TYPE_ID.Color3uint8] = function()
			local r, g, b =
				buffer.readu8(payloadBuffer, loc),
				buffer.readu8(payloadBuffer, loc + 1),
				buffer.readu8(payloadBuffer, loc + 2)
			loc += 3

			return Color3.fromRGB(r, g, b)
		end,

		[TYPE_ID.Font] = function()
			local family = VARIANT_DECODER[TYPE_ID.String]()
			local weight = buffer.readu16(payloadBuffer, loc)
			loc += 2
			local style = buffer.readu8(payloadBuffer, loc)
			loc += 1

			local weightEnum: Enum.FontWeight

			if weight == 100 then
				weightEnum = Enum.FontWeight.Thin
			elseif weight == 200 then
				weightEnum = Enum.FontWeight.ExtraLight
			elseif weight == 300 then
				weightEnum = Enum.FontWeight.Light
			elseif weight == 400 then
				weightEnum = Enum.FontWeight.Regular
			elseif weight == 500 then
				weightEnum = Enum.FontWeight.Medium
			elseif weight == 600 then
				weightEnum = Enum.FontWeight.SemiBold
			elseif weight == 700 then
				weightEnum = Enum.FontWeight.Bold
			elseif weight == 800 then
				weightEnum = Enum.FontWeight.ExtraBold
			elseif weight == 900 then
				weightEnum = Enum.FontWeight.Heavy
			else
				error(`font weight {weight} is not supported or is invalid`)
			end

			local styleEnum: Enum.FontStyle

			if style == 0 then
				styleEnum = Enum.FontStyle.Normal
			elseif style == 1 then
				styleEnum = Enum.FontStyle.Italic
			else
				error(`font style {style} is not supported or is invalid`)
			end

			return Font.new(family, weightEnum, styleEnum)
		end,
	})

	function nextVariant(expectedTypeIds: { number }?)
		-- 1. read type id
		-- 2. loc++;
		-- 3. call type id handler (which uses loc)

		local typeId = buffer.readu8(payloadBuffer, loc)
		loc += 1

		if expectedTypeIds and not table.find(expectedTypeIds, typeId) then
			error(`expected type id inside of array {table.concat(expectedTypeIds, ", ")}, got {typeId}`)
		end

		return assert(VARIANT_DECODER[typeId], "no variant decoder for type id " .. typeId)()
	end

	local rootReferent: string?
	local referentTree: { [string]: Instance } = {}

	local function decodeInstance()
		local name: string = nextVariant({ TYPE_ID.String })
		local className: string = nextVariant({ TYPE_ID.String })
		local instanceReferent: string = nextVariant({ TYPE_ID.Ref })
		local parentReferent: string = nextVariant({ TYPE_ID.Ref, TYPE_ID.None })

		local propertiesLength = buffer.readu16(payloadBuffer, loc)
		local propertiesMap: { [string]: any } = {}
		loc += 2

		while propertiesLength > 0 do
			local start = loc
			while true do
				loc += 1
				if buffer.readu8(payloadBuffer, loc) == 0 then
					-- ensure we skip null byte
					loc += 1
					break
				end
			end

			-- ensure null byte is skipped
			local propertyName = buffer.readstring(payloadBuffer, start, loc - start - 1)
			propertiesMap[propertyName] = nextVariant()
			-- print(propertyName)
			-- print(propertyName, propertiesMap[propertyName])

			propertiesLength -= 1
		end

		local instance: Instance
		if className == "Script" then
			instance = NewScript(propertiesMap.Source or "", nilParentedInstance)
		elseif className == "LocalScript" then
			instance = NewLocalScript(propertiesMap.Source or "", nilParentedInstance)
		elseif className == "ModuleScript" then
			instance = NewModuleScript(propertiesMap.Source or "", nilParentedInstance)
		elseif className == "DataModel" then
			instance = Instance.new("Model")
		else
			instance = Instance.new(className)
		end
		referentTree[instanceReferent] = instance

		instance.Name = name

		if propertiesMap.Attributes then
			for attributeName, value in propertiesMap.Attributes do
				instance:SetAttribute(attributeName, value)
			end

			propertiesMap.Attributes = nil
		end

		if propertiesMap.Tags then
			for _, tag in propertiesMap.Tags do
				instance:AddTag(tag)
			end

			propertiesMap.Tags = nil
		end

		for propertyName, propertyValue in propertiesMap do
			-- TODO: add custom handlers
			local success, error = pcall(function()
				instance[propertyName] = propertyValue
			end)

			if not success then
				warn(`failed setting property {propertyName} with value {propertyValue}; got error {error}`)
			end
		end

		if parentReferent ~= nil then
			instance.Parent = referentTree[parentReferent]
		else
			assert(rootReferent == nil, "there are multiple root referents in the hierarchy")
			rootReferent = instanceReferent
		end

		return instanceReferent
	end

	-- decode entire buffer
	while true do
		local decodedReferent = decodeInstance()
		-- print(`decoded referent {decodedReferent}{if rootReferent == decodedReferent then " [root]" else ""}`)

		if buffer.len(payloadBuffer) == loc then
			-- print("finished decoding payloadBuffer")
			break
		end
	end
	assert(rootReferent, "no root referent in hierarchy")

	return referentTree[rootReferent]
end

-- -- note you can also use zbase64 instead of base64 (zstd compress then base64 the buffer)
-- -- test.bin
-- local payloadBuffer: buffer

-- if game then
-- 	payloadBuffer = game:GetService("HttpService"):JSONDecode([[{"m":null,"t":"buffer","base64":""}]])
-- else
-- 	payloadBuffer = buffer.fromstring(require("@lune/fs").readFile("examples/attributes_and_tags.bin"))
-- end

return decode
