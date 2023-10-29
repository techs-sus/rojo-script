-- rojo-script runtime 'lua-sandbox'
script:Destroy();script=nil
local _7f0905794061d793606d0129edecc19d = { ClassName = "Model", Children = {}, Properties = {} }
_7f0905794061d793606d0129edecc19d.Name = "DataModel"
local _49c6c0d2542ed5cf895bd4f5b2c000fd = { ClassName = "Script", Children = {}, Properties = {} }
_49c6c0d2542ed5cf895bd4f5b2c000fd.Name = "FireEmoji"
_49c6c0d2542ed5cf895bd4f5b2c000fd.Properties.Source = [[ local list = require(script.EmojiList)
print(list.fire)
print(list.water) ]]
_49c6c0d2542ed5cf895bd4f5b2c000fd.Properties.Disabled = false
-- Variant::Tags on ref 49c6c0d2542ed5cf895bd4f5b2c000fd [length: 0]
_49c6c0d2542ed5cf895bd4f5b2c000fd.Tags = {}
-- Variant::Attributes on ref 49c6c0d2542ed5cf895bd4f5b2c000fd [length: 0]
_49c6c0d2542ed5cf895bd4f5b2c000fd.Attributes = {}
_49c6c0d2542ed5cf895bd4f5b2c000fd.Properties.LinkedSource = ""
_7f0905794061d793606d0129edecc19d.Children["_49c6c0d2542ed5cf895bd4f5b2c000fd"] = _49c6c0d2542ed5cf895bd4f5b2c000fd
local _1bdc69dcf130586b8957e9e3b6196ccb = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_1bdc69dcf130586b8957e9e3b6196ccb.Name = "EmojiList"
_1bdc69dcf130586b8957e9e3b6196ccb.Properties.LinkedSource = ""
-- Variant::Attributes on ref 1bdc69dcf130586b8957e9e3b6196ccb [length: 0]
_1bdc69dcf130586b8957e9e3b6196ccb.Attributes = {}
-- Variant::Tags on ref 1bdc69dcf130586b8957e9e3b6196ccb [length: 0]
_1bdc69dcf130586b8957e9e3b6196ccb.Tags = {}
_1bdc69dcf130586b8957e9e3b6196ccb.Properties.Source = [[ local module = {
	fire = "🔥",
	water = "💧"
}

require(script.Test)
-- test the cache
require(script.Test)

return module
 ]]
_49c6c0d2542ed5cf895bd4f5b2c000fd.Children["_1bdc69dcf130586b8957e9e3b6196ccb"] = _1bdc69dcf130586b8957e9e3b6196ccb
local _0cb03833f4f36c36cb27422171369d4e = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_0cb03833f4f36c36cb27422171369d4e.Name = "Test"
-- Variant::Attributes on ref 0cb03833f4f36c36cb27422171369d4e [length: 0]
_0cb03833f4f36c36cb27422171369d4e.Attributes = {}
_0cb03833f4f36c36cb27422171369d4e.Properties.Source = [[ print("Hi from test module ")

local module = {}

return module
 ]]
-- Variant::Tags on ref 0cb03833f4f36c36cb27422171369d4e [length: 0]
_0cb03833f4f36c36cb27422171369d4e.Tags = {}
_0cb03833f4f36c36cb27422171369d4e.Properties.LinkedSource = ""
_1bdc69dcf130586b8957e9e3b6196ccb.Children["_0cb03833f4f36c36cb27422171369d4e"] = _0cb03833f4f36c36cb27422171369d4e
getfenv(0).rootTree = _7f0905794061d793606d0129edecc19d
getfenv(0).rootReferent = "_7f0905794061d793606d0129edecc19d"
type Runtime = {
	getPatchedEnvironment: (script: LuaSourceContainer) -> (),
	loadedModules: {
		[string]: { any },
	},
	main: () -> (),
	require: (script: ModuleScript) -> ...any,
	runScript: (script: LuaSourceContainer) -> (),
}

local runtime: Runtime = {} :: any
if getfenv().__runtime then
	runtime = getfenv().__runtime
else
	runtime.loadedModules = {}

	local HttpService = game:GetService("HttpService")
	local SharedTableRegistry = game:GetService("SharedTableRegistry")
	local rootTree = getfenv(0).rootTree
	local rootReferent = getfenv(0).rootReferent
	local nilProtectedFolder = Instance.new("Folder")
	nilProtectedFolder.Name = "nil-protected-instances"
	nilProtectedFolder.Parent = nil
	local constructorSource = [=[
		local constructInstanceFromTree
		constructInstanceFromTree = function(tree, rootReferent)
			local sourceMap = {}
			local tags = tree.Tags or {}
			local attributes = tree.Attributes or {}
			local children = tree.Children or {}
			local instance = Instance.new(tree.ClassName)
			local root = rootReferent
			local referentsToInstances = {
				[root] = instance,
			}

			local instancesToTrees = {
				[instance] = tree,
			}

			for _, tag in tags do
				instance:AddTag(tag)
			end

			for index, value in attributes do
				instance:SetAttribute(index, value)
			end
			-- ref is inside property

			local instancePropertyReferences = {}
			for index, value in tree.Properties do
				if typeof(value) == "table" and value.ref then
					-- referent
					instancePropertyReferences[instance] = {
						index = index,
						referent = value.ref,
					}
				else
					if index == "Source" then
						sourceMap[instance] = value
					else
						instance[index] = value
					end
				end
			end

			for referent, child in children do
				local childInstance = constructInstanceFromTree(child, referentsToInstances, sourceMap)
				childInstance.Parent = instance
				instancesToTrees[childInstance] = child
				referentsToInstances[referent] = childInstance
			end

			for affectedInstance, info in instancePropertyReferences do
				-- info.index is property, referents[info.referent] is the value
				affectedInstance[info.index] = referentsToInstances[info.referent]
			end

			return instance, referentsToInstances, instancesToTrees, sourceMap
		end

		return constructInstanceFromTree
	]=]
	-- instance, referentsToInstances, instancesToTrees, sourceMap
	type constructInstance = (
		tree: {},
		rootReferent: string
	) -> (Instance, { [string]: Instance }, { [Instance]: string }, { [Instance]: string })

	local constructInstanceFromTree: constructInstance = assert(loadstring(constructorSource))()
	local start = os.clock()

	local rootModel, rootReferentsToInstances, rootInstancesToTrees, sourceMap =
		constructInstanceFromTree(rootTree, rootReferent)
	print(`rojo-script: took {os.clock() - start} seconds to construct instance from tree`)

	local function wrappedNS(source: Script | string, parent: Instance)
		if typeof(source) == "string" then
			return getfenv().NS(source, parent)
		elseif typeof(source) == "Instance" then
			if source:IsA("LuaSourceContainer") then
				-- prevent tampering with objects
				local accessToken = HttpService:GenerateGUID(false)
				local sourcePatch = string.format(
					[[
						--- rojo-script environment tampering ---
						(function()
							-- setup fake tree with a SharedTable
							script:Destroy();
							script = nil
							local accessToken = "%s"
							local SharedTableRegistry = game:GetService("SharedTableRegistry")
							local rootTree = SharedTableRegistry:GetSharedTable("tree-" .. accessToken)
							SharedTableRegistry:SetSharedTable("tree-"..accessToken, nil)
							local rtSource = SharedTableRegistry:GetSharedTable("runtime-" .. accessToken).source
							SharedTableRegistry:SetSharedTable("runtime-"..accessToken, nil)

							local constructorSource = [=[
								%s
							]=]
							type constructInstance = (
								tree: {},
								rootReferent: string
							) -> (Instance, { [string]: Instance }, { [Instance]: string }, { [Instance]: string })
							local constructInstanceFromTree: constructInstance = assert(loadstring(constructorSource))()
							local rootModel, rootReferentsToInstances, rootInstancesToTrees, sourceMap =
								constructInstanceFromTree(rootTree, rootReferent)
							rootModel.Parent = nil
							script = rootModel
							
							-- TODO: Sandbox a "real" script that will appear to the outside world
							-- "real" script will not accept any changes
						end)()
						--- end rojo-script environment tampering ---\n
					]],
					accessToken,
					constructorSource
				)
				SharedTableRegistry:SetSharedTable(
					"tree-" .. accessToken,
					SharedTable.new(rootInstancesToTrees[source])
				)
				SharedTableRegistry:SetSharedTable("runtime-" .. accessToken, SharedTable.new({ source = "rtSource" }))
				local created: Script = getfenv().NS(sourcePatch .. sourceMap[source], nilProtectedFolder)
				created.Parent = parent
				return created
			else
				error("expected instance LuaSourceContainer" .. " but got " .. source.ClassName)
			end
		else
			error("expected type string | LuaSourceContainer" .. " but got " .. typeof(source))
		end
	end

	local function wrappedNLS(source: LocalScript | string, parent: Instance)
		if typeof(source) == "string" then
			return getfenv().NLS(source, parent)
		elseif typeof(source) == "Instance" then
			if source:IsA("LocalScript") then
				-- transfer instances from source to new script
				-- nil parent prevents execution for localscripts
				local remote = Instance.new("RemoteEvent")
				local created = getfenv().NLS(sourceMap[source], nilProtectedFolder)
				created.Disabled = true
				-- we cant init on client because people parent remotes to locals
				-- and i dont want to make a full instance sandbox
				for _, v in source:Clone():GetChildren() do
					v.Parent = created
				end
				-- run it
				created.Disabled = false
				created.Parent = parent
				remote:FireClient(getfenv(0).owner, rootInstancesToTrees[source])
				return created
			else
				error("expected class LocalScript" .. " but got " .. source.ClassName)
			end
		else
			error("expected type string | LocalScript" .. " but got " .. typeof(source))
		end
	end

	function runtime.getPatchedEnvironment(script)
		local e
		e = setmetatable({
			script = script,
			getfenv = function()
				return e
			end,
			require = runtime.require,
			NLS = wrappedNLS,
			NS = wrappedNS,
			__runtime = runtime,
		}, {
			__index = getfenv(0),
			__metatable = "The metatable is locked",
		})
		return e
	end

	runtime.require = function(script): ...any
		if typeof(script) == "number" then
			return require(script)
		end
		if not script:IsA("ModuleScript") then
			return error("Instance is not a ModuleScript")
		end
		if runtime.loadedModules[script] then
			return unpack(runtime.loadedModules[script])
		end
		local source = sourceMap[script]
		local environment = runtime.getPatchedEnvironment(script)
		local fn: ((...any) -> ...any)?, e: string? = loadstring(source)
		if not fn then
			error("Error loading module, loadstring failed " .. if e then e else "(no error)")
		else
			setfenv(fn, environment)
			local returns = { fn() }
			if #returns ~= 1 then
				error("The module did not return exactly one value, " .. script:GetFullName())
			end

			runtime.loadedModules[script] = returns
			return unpack(runtime.loadedModules[script])
		end
	end

	local function runScript(script: LuaSourceContainer)
		local source = sourceMap[script]
		local fn, e = loadstring(source)
		local environment = runtime.getPatchedEnvironment(script)
		if not fn then
			error("Error running script, loadstring failed " .. if e then e else "(no error)")
		end
		setfenv(fn, environment)
		coroutine.wrap(fn)()
	end

	local safeContainer = Instance.new("Script")
	safeContainer.Name = "Script"
	rootModel.Parent = safeContainer
	safeContainer.Parent = workspace

	function runtime.main()
		-- getchildren is impossible for rojo projects
		for _, instance in rootModel:GetDescendants() do
			if instance:IsA("Script") and not instance.Disabled then
				runScript(instance)
			end
		end
	end

	runtime.runScript = runScript
	runtime.main()
end
