-- rojo-script runtime 'lua-sandbox'
local sourceMap = {}
local _b70ba8da441fb1e6998bd359cf5dab28 = Instance.new("Model")
_b70ba8da441fb1e6998bd359cf5dab28.Name = "DataModel"
local _f3f889bd60de5ce939e0e841a342d2f2 = Instance.new("Script")
_f3f889bd60de5ce939e0e841a342d2f2.Name = "FireEmoji"
sourceMap[_f3f889bd60de5ce939e0e841a342d2f2] = [===[ local list = require(script.EmojiList)
print(list.fire)
print(list.water) ]===]
_f3f889bd60de5ce939e0e841a342d2f2.LinkedSource = ""
-- tags for ref f3f889bd60de5ce939e0e841a342d2f2 with length 0
_f3f889bd60de5ce939e0e841a342d2f2.Disabled = false
-- attributes for ref f3f889bd60de5ce939e0e841a342d2f2 with length 0
_f3f889bd60de5ce939e0e841a342d2f2.Parent = _b70ba8da441fb1e6998bd359cf5dab28
local _1c1251080cbbad2da4a7828eefaab5b6 = Instance.new("ModuleScript")
_1c1251080cbbad2da4a7828eefaab5b6.Name = "EmojiList"
_1c1251080cbbad2da4a7828eefaab5b6.LinkedSource = ""
-- attributes for ref 1c1251080cbbad2da4a7828eefaab5b6 with length 0
sourceMap[_1c1251080cbbad2da4a7828eefaab5b6] = [===[ local module = {
	fire = "🔥",
	water = "💧"
}

require(script.Test)
-- test the cache
require(script.Test)

return module
 ]===]
-- tags for ref 1c1251080cbbad2da4a7828eefaab5b6 with length 0
_1c1251080cbbad2da4a7828eefaab5b6.Parent = _f3f889bd60de5ce939e0e841a342d2f2
local _ed9e6e32cdc006f51f4e66ff3c91efd4 = Instance.new("ModuleScript")
_ed9e6e32cdc006f51f4e66ff3c91efd4.Name = "Test"
sourceMap[_ed9e6e32cdc006f51f4e66ff3c91efd4] = [===[ print("Hi from test module ")

local module = {}

return module
 ]===]
-- attributes for ref ed9e6e32cdc006f51f4e66ff3c91efd4 with length 0
-- tags for ref ed9e6e32cdc006f51f4e66ff3c91efd4 with length 0
_ed9e6e32cdc006f51f4e66ff3c91efd4.LinkedSource = ""
_ed9e6e32cdc006f51f4e66ff3c91efd4.Parent = _1c1251080cbbad2da4a7828eefaab5b6
local root = _b70ba8da441fb1e6998bd359cf5dab28
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
