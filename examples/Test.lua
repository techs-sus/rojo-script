-- rojo-script runtime 'lua-sandbox'
local sourceMap = {}
local _fe5cb0ca1d54285dc7287f040029320e = Instance.new("Model")
_fe5cb0ca1d54285dc7287f040029320e.Name = "DataModel"
local _981df297d5c679ce1f3f5d99d54e15bc = Instance.new("Script")
_981df297d5c679ce1f3f5d99d54e15bc.Name = "FireEmoji"
_981df297d5c679ce1f3f5d99d54e15bc.LinkedSource = ""
sourceMap[_981df297d5c679ce1f3f5d99d54e15bc] = [===[ local list = require(script.EmojiList)
print(list.fire)
print(list.water) ]===]
-- tags for ref 981df297d5c679ce1f3f5d99d54e15bc with length 0
_981df297d5c679ce1f3f5d99d54e15bc.Disabled = false
-- attributes for ref 981df297d5c679ce1f3f5d99d54e15bc with length 0
_981df297d5c679ce1f3f5d99d54e15bc.Parent = _fe5cb0ca1d54285dc7287f040029320e
local _8bad2aad5f13aa4b316d9bf6318b3f68 = Instance.new("ModuleScript")
_8bad2aad5f13aa4b316d9bf6318b3f68.Name = "EmojiList"
-- attributes for ref 8bad2aad5f13aa4b316d9bf6318b3f68 with length 0
sourceMap[_8bad2aad5f13aa4b316d9bf6318b3f68] = [===[ local module = {
	fire = "🔥",
	water = "💧"
}

require(script.Test)
-- test the cache
require(script.Test)

return module
 ]===]
-- tags for ref 8bad2aad5f13aa4b316d9bf6318b3f68 with length 0
_8bad2aad5f13aa4b316d9bf6318b3f68.LinkedSource = ""
_8bad2aad5f13aa4b316d9bf6318b3f68.Parent = _981df297d5c679ce1f3f5d99d54e15bc
local _6b8d9ea8b696c2c15fb969c9b713aef5 = Instance.new("ModuleScript")
_6b8d9ea8b696c2c15fb969c9b713aef5.Name = "Test"
sourceMap[_6b8d9ea8b696c2c15fb969c9b713aef5] = [===[ print("Hi from test module "); require(213)

local module = {}

return module
 ]===]
-- attributes for ref 6b8d9ea8b696c2c15fb969c9b713aef5 with length 0
-- tags for ref 6b8d9ea8b696c2c15fb969c9b713aef5 with length 0
_6b8d9ea8b696c2c15fb969c9b713aef5.LinkedSource = ""
_6b8d9ea8b696c2c15fb969c9b713aef5.Parent = _8bad2aad5f13aa4b316d9bf6318b3f68
local root = _fe5cb0ca1d54285dc7287f040029320e
local loadedModules = {}
local fakeRequire: (ModuleScript) -> ...any

local function wrapNew(fn: (string | Instance, Instance) -> LuaSourceContainer, class: string)
	return function(source, parent)
		if typeof(source) == "string" then
			return fn(source, parent)
		elseif typeof(source) == "Instance" then
			if source:IsA(class) then
				-- transfer instances from source to new script
				-- nil parent prevents execution for localscripts
				local created = fn(sourceMap[source], nil)
				created.Disabled = true
				for _, v in source:GetChildren() do
					v.Parent = created
				end
				-- run it
				created.Disabled = false
				created.Parent = parent
				return created
			else
				error("(rojo-script) instance is not a " .. class)
			end
		end
	end
end

local wrappedNLS = wrapNew(NLS, "LocalScript")
local wrappedNS = wrapNew(NS, "Script")
fakeRequire = function(script)
	if typeof(script) == "number" then
		-- i cant test this because i don't have require perms
		return require(script)
	end
	if not script:IsA("ModuleScript") then
		return error("Instance is not a ModuleScript")
	end
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
	local fn: (() -> any)?, e: string? = loadstring(source)
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
	setfenv(fn, environment)
	coroutine.wrap(fn)()
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
