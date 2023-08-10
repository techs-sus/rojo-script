-- rojo-script runtime 'lua-sandbox'
local sourceMap = {}
local _d711a28e484f17b03cf7f550bd72f2ea = Instance.new("Model")
_d711a28e484f17b03cf7f550bd72f2ea.Name = "DataModel"
local _76b18cb24d44e07e40a87b4d4328ff53 = Instance.new("Script")
_76b18cb24d44e07e40a87b4d4328ff53.Name = "FireEmoji"
_76b18cb24d44e07e40a87b4d4328ff53.Disabled = false
-- attributes for ref 76b18cb24d44e07e40a87b4d4328ff53 with length 0
sourceMap[_76b18cb24d44e07e40a87b4d4328ff53] = [===[ local list = require(script.EmojiList)
print(list.fire)
print(list.water) ]===]
_76b18cb24d44e07e40a87b4d4328ff53.LinkedSource = ""
-- tags for ref 76b18cb24d44e07e40a87b4d4328ff53 with length 0
_76b18cb24d44e07e40a87b4d4328ff53.Parent = _d711a28e484f17b03cf7f550bd72f2ea
local _183774eb4dbe110c74512976d0f6fc04 = Instance.new("ModuleScript")
_183774eb4dbe110c74512976d0f6fc04.Name = "EmojiList"
-- attributes for ref 183774eb4dbe110c74512976d0f6fc04 with length 0
-- tags for ref 183774eb4dbe110c74512976d0f6fc04 with length 0
sourceMap[_183774eb4dbe110c74512976d0f6fc04] = [===[ local module = {
	fire = "🔥",
	water = "💧"
}

require(script.Test)
-- test the cache
require(script.Test)

return module
 ]===]
_183774eb4dbe110c74512976d0f6fc04.LinkedSource = ""
_183774eb4dbe110c74512976d0f6fc04.Parent = _76b18cb24d44e07e40a87b4d4328ff53
local _437739da83c68047bf2bbe27851c88cf = Instance.new("ModuleScript")
_437739da83c68047bf2bbe27851c88cf.Name = "Test"
-- attributes for ref 437739da83c68047bf2bbe27851c88cf with length 0
sourceMap[_437739da83c68047bf2bbe27851c88cf] = [===[ print("Hi from test module ")

local module = {}

return module
 ]===]
-- tags for ref 437739da83c68047bf2bbe27851c88cf with length 0
_437739da83c68047bf2bbe27851c88cf.LinkedSource = ""
_437739da83c68047bf2bbe27851c88cf.Parent = _183774eb4dbe110c74512976d0f6fc04
local root = _d711a28e484f17b03cf7f550bd72f2ea
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

for _, instance in root:GetChildren() do
	if instance:IsA("Script") and not instance.Disabled then
		runScript(instance)
	end
end
