local loadedModules = {}
local fakeRequire

local function wrapNew(fn, class)
	return function(source, parent)
		if typeof(source) == "string" then
			return fn(source, parent)
		elseif typeof(source) == "Instance" then
			if source:IsA(class) then
				return fn(sourceMap[source], parent)
			else
				error("(rojo-script) instance is not a " .. class)
			end
		end
	end
end

local wrappedNLS = wrapNew(NLS, "LocalScript")
local wrappedNS = wrapNew(NS, "Script")
fakeRequire = function(script)
	if loadedModules[script] then
		return unpack(loadedModules[script])
	end
	local source = sourceMap[script]
	local environment
	environment = setmetatable({
		script = script,
		getfenv = function()
			return environment
		end,
		require = fakeRequire,
		NLS = wrappedNLS,
		NS = wrappedNS,
		realScript = getfenv(0).script,
	}, {
		__index = getfenv(0),
		__metatable = "The metatable is locked",
	})
	local fn, e = loadstring(source)
	if not fn then
		error("Error loading module, loadstring failed", e)
	end
	setfenv(fn, environment)
	loadedModules[script] = { fn() }
	return unpack(loadedModules[script])
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
		require = fakeRequire,
		NLS = wrappedNLS,
		NS = wrappedNS,
		realScript = getfenv(0).script,
	}, {
		__index = getfenv(0),
		__metatable = "The metatable is locked",
	})
	if not fn then
		error("Error running script, loadstring failed", e)
	end
	coroutine.wrap(function()
		setfenv(fn, environment)
		if not fn then
			error("Error patching environment")
		else
			fn()
		end
	end)()
end

local safeContainer = Instance.new("Script")
safeContainer.Name = "Script"
root.Parent = safeContainer
safeContainer.Parent = workspace

-- getchildren is impossible for rojo projects
for _, instance in root:GetDescendants() do
	if instance:IsA("Script") and not instance.Disabled then
		runScript(instance)
	end
end
