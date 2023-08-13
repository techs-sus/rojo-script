local runtime
if getfenv().__runtime then
	runtime = getfenv().__runtime
else
	runtime = {
		loadedModules = {},
		bindable = Instance.new("BindableFunction"),
	}
	local nilParentedInstance = Instance.new("Script")
	nilParentedInstance.Name = "<nil>"
	nilParentedInstance.Parent = nil

	local function wrapNew(fn: (string | Instance, Instance) -> LuaSourceContainer, class: string)
		return function(source, parent)
			if typeof(source) == "string" then
				return fn(source, parent)
			elseif typeof(source) == "Instance" then
				if source:IsA(class) then
					-- transfer instances from source to new script
					-- nil parent prevents execution for localscripts
					local created = fn(sourceMap[source], nilParentedInstance)
					created.Disabled = true
					for _, v in source:GetChildren() do
						v.Parent = created
					end
					-- run it
					created.Disabled = false
					created.Parent = parent
					return created
				else
					error("expected class " .. class .. " but got " .. source.ClassName)
				end
			else
				error("expected type string | " .. class .. " but got " .. typeof(source))
			end
		end
	end

	local wrappedNLS = wrapNew(getfenv().NLS, "LocalScript")
	local wrappedNS = wrapNew(getfenv().NS, "Script")
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
	end
	-- this will be used in another commit :)
	runtime.bindable.OnInvoke = function(script)
		return runtime.getPatchedEnvironment(script)
	end

	runtime.require = function(script): ...any
		if typeof(script) == "number" then
			-- i cant test this because i don't have require perms
			return require(script)
		end
		if not script:IsA("ModuleScript") then
			return error("Instance is not a ModuleScript")
		end
		if runtime.loadedModules[script] then
			return unpack(runtime.loadedModules[script])
		end
		local source = sourceMap[script]
		local environment
		environment = runtime.getPatchedEnvironment(script)
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
		local environment
		environment = setmetatable({
			script = script,
			getfenv = function()
				return environment
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
