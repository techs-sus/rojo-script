local ServerScriptService = game:GetService("ServerScriptService")
local loadedModules = {}

local fakeRequire
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

root.Parent = ServerScriptService

for _, instance in root:GetChildren() do
	if instance:IsA("Script") and not instance.Disabled then
		runScript(instance)
	end
end
