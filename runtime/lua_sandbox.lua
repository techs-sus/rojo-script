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
	local HttpService = game:GetService("HttpService")
	local root: Model = getfenv(0).root
	local sourceMap = getfenv(0).sourceMap
	runtime.loadedModules = {}
	local nilParentedInstance = Instance.new("Script")
	nilParentedInstance.Name = "<nil>"
	nilParentedInstance.Parent = nil

	local function wrappedNS(source: Script | string, parent: Instance)
		if typeof(source) == "string" then
			return getfenv().NS(source, parent)
		elseif typeof(source) == "Instance" then
			if source:IsA("Script") then
				-- prevent tampering
				local accessToken = HttpService:GenerateGUID(false)
				local sourcePatch = string.format(
					[[
						--- rojo-script environment tampering ---
						(function()
							repeat task.wait() until script.Parent:IsA("Actor")
							local communication = script.Parent
							local token = "%s"
							local c
							c = communication:BindToMessage(token .. "| runtime::getPatchedEnvironment<return>", function(environment)
								setfenv(0, environment);
								c:Disconnect()
							end)
							communication:SendMessage(token .. "| runtime::getPatchedEnvironment", script)
						end)()

					]],
					accessToken
				)
				-- transfer instances from source to new script
				-- nil parent prevents execution for localscripts

				local created = getfenv().NLS(sourcePatch .. sourceMap[source], nilParentedInstance)
				local connection
				local communication = Instance.new("Actor")
				created.Disabled = true
				-- TODO: Make adding instances to the source safe.
				for _, v in source:GetChildren() do
					v.Parent = created
				end
				-- run it
				created.Disabled = false
				connection = communication:BindToMessage(
					accessToken .. "| runtime::getPatchedEnvironment",
					function(script)
						if script ~= created then
							return
						end
						communication:SendMessage(
							accessToken .. "| runtime::getPatchedEnvironment<return>",
							runtime.getPatchedEnvironment(script)
						)
						created.Parent = parent
						connection:Disconnect()
					end
				)
				-- take 20 cycles to ensure script has been ran
				local amplify = table.create(20, task.defer)
				created.Parent = parent
				pcall(amplify, function()
					created.Parent = communication
				end)
				return created
			else
				error("expected class Script" .. " but got " .. source.ClassName)
			end
		else
			error("expected type string | Script" .. " but got " .. typeof(source))
		end
	end

	local function wrappedNLS(source: LocalScript | string, parent: Instance)
		if typeof(source) == "string" then
			return getfenv().NLS(source, parent)
		elseif typeof(source) == "Instance" then
			if source:IsA("LocalScript") then
				-- transfer instances from source to new script
				-- nil parent prevents execution for localscripts

				local created = getfenv().NLS(sourceMap[source], nilParentedInstance)
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
			realScript = getfenv(0).script,
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
			error("Error loading module, loadstring failed " .. if e then e else "no error")
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
	root.Parent = safeContainer
	safeContainer.Parent = workspace

	function runtime.main()
		-- getchildren is impossible for rojo projects
		for _, instance in root:GetDescendants() do
			if instance:IsA("Script") and not instance.Disabled then
				runScript(instance)
			end
		end
	end

	runtime.runScript = runScript
	runtime.main()
end
