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
	local referentMap = getfenv(0).referentMap
	local nilProtectedFolder = Instance.new("Folder")
	nilProtectedFolder.Name = "nil-protected-instances"
	nilProtectedFolder.Parent = nil
	local constructorSource = string.format(
		[[
		local constructInstanceFromTree
		constructInstanceFromTree = function(tree, referents, sourceMap)
			local sourceMap = sourceMap or {}
			local tags = tree.Tags or {}
			local attributes = tree.Attributes or {}
			local children = tree.Children or {}
			local instance = Instance.new(tree.ClassName)
			if not referents then
				referents = {
					["%s"] = instance,
				}
			end

			for _, tag in tags do
				instance:AddTag(tag)
			end

			for index, value in attributes do
				instance:SetAttribute(index, value)
			end
			-- ref is inside property

			local instancePropertyReferences = {}
			for index, value in tree do
				if index ~= "Tags" and index ~= "Attributes" and index ~= "Children" and index ~= "ClassName" then
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
			end

			for _, child in children do
				referents[referent] = constructInstanceFromTree(child, referents, sourceMap)
				referents[referent].Parent = instance
			end

			for affectedInstance, info in instancePropertyReferences do
				affectedInstance[info.index] = referents[info.referent]
			end

			return instance, referents, sourceMap
		end
		return constructInstanceFromTree
	]],
		rootReferent
	)
	-- instance, referents, sourceMap
	local constructInstanceFromTree: (tree: {}, referents: {}?, sourceMap: {}?) -> (Instance, { [string]: Instance }, { [Instance]: string }) =
		loadstring(constructorSource)()
	local rootModel, rootReferents, sourceMap = constructInstanceFromTree(rootTree)

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
							local rootTree = SharedTableRegistry:GetSharedTable(accessToken)
							SharedTableRegistry:SetSharedTable(accessToken, nil)

							local constructorSource = [=[
								%s
							]=]
							local constructInstanceFromTree: (tree: {}, referents: {}?, sourceMap: {}?) -> (Instance, { [Instance]: string }) = loadstring(constructorSource)()
							local newInstance = constructInstanceFromTree(rootTree)
							newInstance.Parent = nil
							script = newInstance
							
							-- TODO: Sandbox a "real" script that will appear to the outside world
							-- "real" script will not accept any changes
						end)()
						--- end rojo-script environment tampering ---\n
					]],
					accessToken,
					constructorSource
				)
				SharedTableRegistry:SetSharedTable(accessToken, SharedTable.new(referentMap[source]))
				local created: Script = getfenv().NS(sourcePatch .. sourceMap[source], nilProtectedFolder)
				-- while parenting to nilProtectedFolder does prevent script execution,
				-- we should still disable it until its safe to continue
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

				local created = getfenv().NLS(sourceMap[source], nilProtectedFolder)
				created.Disabled = true
				-- TODO: Make adding instances to the source safe.
				for _, v in source:GetChildren() do
					v.Parent = created
				end
				-- run it
				created.Disabled = false
				created.Parent = parent
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
			runtime.loadedModules[script] = { fn() }
			return unpack(runtime.loadedModules[script])
		end
	end

	local function runScript(script: LuaSourceContainer)
		local source = sourceMap[script]
		local fn, e = loadstring(source)
		local environment = runtime.getPatchedEnvironment(script)
		if not fn then
			error("Error running script, loadstring failed", e)
		end
		setfenv(fn, environment)
		coroutine.wrap(fn)()
	end

	local safeContainer = Instance.new("Script")
	safeContainer.Name = "Script"
	rootTree.Parent = safeContainer
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
