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
			-- this is untested
			local length = buffer.readu16(payloadBuffer, loc)

			if length == 0 then
				loc += 3
				return {}
			end

			loc += 2
			local tags = {}

			local start = loc
			while length > 0 do
				if buffer.readu8(payloadBuffer, loc) == 0 then
					table.insert(tags, buffer.readstring(payloadBuffer, start, loc - start))
					start = loc
					length -= 1
				end
				loc += 1
			end

			return tags
		end,

		[TYPE_ID.Attributes] = function()
			local attributesLength = buffer.readu16(payloadBuffer, loc)
			loc += 2

			local attributeMap: { [string]: any } = {}
			while attributesLength > 0 do
				local tmp = ""

				while true do
					local byte = buffer.readu8(payloadBuffer, loc)
					if byte == 0 then
						-- string finished
						break
					else
						tmp ..= string.char(byte)
						loc += 1
					end
				end

				local attributeName = tmp
				loc += 1
				attributeMap[attributeName] = nextVariant()
				print(attributesLength)
				print("attribute name", attributeName, attributeMap[attributeName])

				attributesLength -= 1
			end

			return attributeMap
		end,

		[TYPE_ID.SecurityCapabilities] = function()
			-- skip
			loc += 8
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

			local propertyName = buffer.readstring(payloadBuffer, start, loc - start)
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
		end

		if propertiesMap.Tags then
			for _, tag in propertiesMap.Tags do
				instance:AddTag(tag)
			end
		end

		for propertyName, propertyValue in propertiesMap do
			-- TODO: add custom handlers
			if propertyName == "Tags" or propertyName == "Attributes" then
				continue
			end

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
		print(`decoded referent {decodedReferent}{if rootReferent == decodedReferent then " [root]" else ""}`)

		if buffer.len(payloadBuffer) == loc then
			print("finished decoding payloadBuffer")
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
