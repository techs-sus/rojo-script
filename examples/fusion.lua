-- rojo-script runtime 'lua-sandbox'
script:Destroy();script=nil
local _c781ff795ccaae172b8a8013d25039e5 = { ClassName = "Model", Children = {}, Properties = {} }
_c781ff795ccaae172b8a8013d25039e5.Name = "DataModel"
local _d56864cbc3c61714243504ffab872304 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_d56864cbc3c61714243504ffab872304.Name = "Fusion"
_d56864cbc3c61714243504ffab872304.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler
--\[\[
	The entry point for the Fusion library.
\]\]

local Types = require(script.Types)
local External = require(script.External)

export type Animatable = Types.Animatable
export type UsedAs<T> = Types.UsedAs<T>
export type Child = Types.Child
export type Computed<T> = Types.Computed<T>
export type Contextual<T> = Types.Contextual<T>
export type Dependency = Types.Dependency
export type Dependent = Types.Dependent
export type For<KO, VO> = Types.For<KO, VO>
export type Observer = Types.Observer
export type PropertyTable = Types.PropertyTable
export type Scope<Constructors> = Types.Scope<Constructors>
export type ScopedObject = Types.ScopedObject
export type SpecialKey = Types.SpecialKey
export type Spring<T> = Types.Spring<T>
export type StateObject<T> = Types.StateObject<T>
export type Task = Types.Task
export type Tween<T> = Types.Tween<T>
export type Use = Types.Use
export type Value<T, S = T> = Types.Value<T, S>
export type Version = Types.Version

-- Down the line, this will be conditional based on whether Fusion is being
-- compiled for Roblox.
do
	local RobloxExternal = require(script.RobloxExternal)
	External.setExternalScheduler(RobloxExternal)
end

local Fusion: Types.Fusion = {
	-- General
	version = {major = 0, minor = 3, isRelease = false},
	Contextual = require(script.Utility.Contextual),
	Safe = require(script.Utility.Safe),

	-- Memory
	cleanup = require(script.Memory.legacyCleanup),
	deriveScope = require(script.Memory.deriveScope),
	doCleanup = require(script.Memory.doCleanup),
	innerScope = require(script.Memory.innerScope),
	scoped = require(script.Memory.scoped),
	
	-- State
	Computed = require(script.State.Computed),
	ForKeys = require(script.State.ForKeys) :: Types.ForKeysConstructor,
	ForPairs = require(script.State.ForPairs) :: Types.ForPairsConstructor,
	ForValues = require(script.State.ForValues) :: Types.ForValuesConstructor,
	Observer = require(script.State.Observer),
	peek = require(script.State.peek),
	Value = require(script.State.Value),

	-- Roblox API
	Attribute = require(script.Instances.Attribute),
	AttributeChange = require(script.Instances.AttributeChange),
	AttributeOut = require(script.Instances.AttributeOut),
	Children = require(script.Instances.Children),
	Hydrate = require(script.Instances.Hydrate),
	New = require(script.Instances.New),
	OnChange = require(script.Instances.OnChange),
	OnEvent = require(script.Instances.OnEvent),
	Out = require(script.Instances.Out),
	Ref = require(script.Instances.Ref),

	-- Animation
	Tween = require(script.Animation.Tween),
	Spring = require(script.Animation.Spring),
}

return Fusion ]]
_c781ff795ccaae172b8a8013d25039e5.Children["_d56864cbc3c61714243504ffab872304"] = _d56864cbc3c61714243504ffab872304
local _d56864cbc3c61714243504ffab872304 = nil -- DEALLOCATE PLS :pray:
local _c0d361e4644871baf04d173a22202ee8 = { ClassName = "Folder", Children = {}, Properties = {} }
_c0d361e4644871baf04d173a22202ee8.Name = "Animation"
_d56864cbc3c61714243504ffab872304.Children["_c0d361e4644871baf04d173a22202ee8"] = _c0d361e4644871baf04d173a22202ee8
local _c0d361e4644871baf04d173a22202ee8 = nil -- DEALLOCATE PLS :pray:
local _e39c60d2a708c84011f4d3f1e59a5402 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_e39c60d2a708c84011f4d3f1e59a5402.Name = "Spring"
_e39c60d2a708c84011f4d3f1e59a5402.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Constructs a new computed state object, which follows the value of another
	state object using a spring simulation.
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local InternalTypes = require(Package.InternalTypes)
local logError = require(Package.Logging.logError)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local unpackType = require(Package.Animation.unpackType)
local SpringScheduler = require(Package.Animation.SpringScheduler)
local updateAll = require(Package.State.updateAll)
local isState = require(Package.State.isState)
local peek = require(Package.State.peek)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)
local logWarn = require(Package.Logging.logWarn)

local class = {}
class.type = "State"
class.kind = "Spring"

local CLASS_METATABLE = {__index = class}

--\[\[
	Sets the position of the internal springs, meaning the value of this
	Spring will jump to the given value. This doesn't affect velocity.

	If the type doesn't match the current type of the spring, an error will be
	thrown.
\]\]
function class:setPosition(
	newValue: Types.Animatable
)
	local self = self :: InternalTypes.Spring<unknown>
	local newType = typeof(newValue)
	if newType ~= self._currentType then
		logError("springTypeMismatch", nil, newType, self._currentType)
	end

	self._springPositions = unpackType(newValue, newType)
	self._currentValue = newValue
	SpringScheduler.add(self)
	updateAll(self)
end

--\[\[
	Sets the velocity of the internal springs, overwriting the existing velocity
	of this Spring. This doesn't affect position.

	If the type doesn't match the current type of the spring, an error will be
	thrown.
\]\]
function class:setVelocity(
	newValue: Types.Animatable
)
	local self = self :: InternalTypes.Spring<unknown>
	local newType = typeof(newValue)
	if newType ~= self._currentType then
		logError("springTypeMismatch", nil, newType, self._currentType)
	end

	self._springVelocities = unpackType(newValue, newType)
	SpringScheduler.add(self)
end

--\[\[
	Adds to the velocity of the internal springs, on top of the existing
	velocity of this Spring. This doesn't affect position.

	If the type doesn't match the current type of the spring, an error will be
	thrown.
\]\]
function class:addVelocity(
	deltaValue: Types.Animatable
)
	local self = self :: InternalTypes.Spring<unknown>
	local deltaType = typeof(deltaValue)
	if deltaType ~= self._currentType then
		logError("springTypeMismatch", nil, deltaType, self._currentType)
	end

	local springDeltas = unpackType(deltaValue, deltaType)
	for index, delta in ipairs(springDeltas) do
		self._springVelocities[index] += delta
	end
	SpringScheduler.add(self)
end

--\[\[
	Called when the goal state changes value, or when the speed or damping has
	changed.
\]\]
function class:update(): boolean
	local self = self :: InternalTypes.Spring<unknown>
	local goalValue = peek(self._goal)

	-- figure out if this was a goal change or a speed/damping change
	if goalValue == self._goalValue then
		-- speed/damping change
		local damping = peek(self._damping)
		if typeof(damping) ~= "number" then
			logErrorNonFatal("mistypedSpringDamping", nil, typeof(damping))
		elseif damping < 0 then
			logErrorNonFatal("invalidSpringDamping", nil, damping)
		else
			self._currentDamping = damping
		end

		local speed = peek(self._speed)
		if typeof(speed) ~= "number" then
			logErrorNonFatal("mistypedSpringSpeed", nil, typeof(speed))
		elseif speed < 0 then
			logErrorNonFatal("invalidSpringSpeed", nil, speed)
		else
			self._currentSpeed = speed
		end

		return false
	else
		-- goal change - reconfigure spring to target new goal
		self._goalValue = goalValue

		local oldType = self._currentType
		local newType = typeof(goalValue)
		self._currentType = newType

		local springGoals = unpackType(goalValue, newType)
		local numSprings = #springGoals
		self._springGoals = springGoals

		if newType ~= oldType then
			-- if the type changed, snap to the new value and rebuild the
			-- position and velocity tables
			self._currentValue = self._goalValue

			local springPositions = table.create(numSprings, 0)
			local springVelocities = table.create(numSprings, 0)
			for index, springGoal in ipairs(springGoals) do
				springPositions[index] = springGoal
			end
			self._springPositions = springPositions
			self._springVelocities = springVelocities

			-- the spring may have been animating before, so stop that
			SpringScheduler.remove(self)
			return true

			-- otherwise, the type hasn't changed, just the goal...
		elseif numSprings == 0 then
			-- if the type isn't animatable, snap to the new value
			self._currentValue = self._goalValue
			return true

		else
			-- if it's animatable, let it animate to the goal
			SpringScheduler.add(self)
			return false
		end
	end
end

--\[\[
	Returns the interior value of this state object.
\]\]
function class:_peek(): unknown
	local self = self :: InternalTypes.Spring<unknown>
	return self._currentValue
end

function class:get()
	logError("stateGetWasRemoved")
end

function class:destroy()
	local self = self :: InternalTypes.Spring<unknown>
	if self.scope == nil then
		logError("destroyedTwice", nil, "Spring")
	end
	SpringScheduler.remove(self)
	self.scope = nil
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end
end

local function Spring<T>(
	scope: Types.Scope<unknown>,
	goal: Types.UsedAs<T>,
	speed: Types.UsedAs<number>?,
	damping: Types.UsedAs<number>?
): Types.Spring<T>
	if typeof(scope) ~= "table" or isState(scope) then
		logError("scopeMissing", nil, "Springs", "myScope:Spring(goalState, speed, damping)")
	end
	-- apply defaults for speed and damping
	if speed == nil then
		speed = 10
	end
	if damping == nil then
		damping = 1
	end

	local dependencySet: {[Types.Dependency]: unknown} = {}
	local goalIsState = isState(goal)
	if goalIsState then
		local goal = goal :: Types.StateObject<T>
		dependencySet[goal] = true
	end
	if isState(speed) then
		local speed = speed :: Types.StateObject<number>
		dependencySet[speed] = true
	end
	if isState(damping) then
		local damping = damping :: Types.StateObject<number>
		dependencySet[damping] = true
	end

	local self = setmetatable({
		scope = scope,
		dependencySet = dependencySet,
		dependentSet = {},
		_speed = speed,
		_damping = damping,

		_goal = goal,
		_goalValue = nil,

		_currentType = nil,
		_currentValue = nil,
		_currentSpeed = peek(speed),
		_currentDamping = peek(damping),

		_springPositions = nil,
		_springGoals = nil,
		_springVelocities = nil,

		_lastSchedule = -math.huge,
		_startDisplacements = {},
		_startVelocities = {}
	}, CLASS_METATABLE)
	local self = (self :: any) :: InternalTypes.Spring<T>

	table.insert(scope, self)
	
	if goalIsState then
		local goal = goal :: Types.StateObject<T>
		if goal.scope == nil then
			logError("useAfterDestroy", nil, `The {goal.kind} object`, `the Spring that is following it`)
		elseif whichLivesLonger(scope, self, goal.scope, goal) == "definitely-a" then
			logWarn("possiblyOutlives", `The {goal.kind} object`, `the Spring that is following it`)
		end
		-- add this object to the goal state's dependent set
		goal.dependentSet[self] = true
	end

	self:update()

	return self
end

return Spring ]]
_c0d361e4644871baf04d173a22202ee8.Children["_e39c60d2a708c84011f4d3f1e59a5402"] = _e39c60d2a708c84011f4d3f1e59a5402
local _e39c60d2a708c84011f4d3f1e59a5402 = nil -- DEALLOCATE PLS :pray:

local _b5fe21077e1a3ad6dbb6beea6bc5d048 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_b5fe21077e1a3ad6dbb6beea6bc5d048.Name = "SpringScheduler"
_b5fe21077e1a3ad6dbb6beea6bc5d048.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Manages batch updating of spring objects.
\]\]

local Package = script.Parent.Parent
local InternalTypes = require(Package.InternalTypes)
local External = require(Package.External)
local packType = require(Package.Animation.packType)
local springCoefficients = require(Package.Animation.springCoefficients)
local updateAll = require(Package.State.updateAll)
local logWarn = require(Package.Logging.logWarn)

type Set<T> = {[T]: unknown}

local SpringScheduler = {}

local EPSILON = 0.0001
local activeSprings: Set<InternalTypes.Spring<unknown>> = {}
local lastUpdateTime = External.lastUpdateStep()

function SpringScheduler.add(
	spring: InternalTypes.Spring<unknown>
)
	-- we don't necessarily want to use the most accurate time - here we snap to
	-- the last update time so that springs started within the same frame have
	-- identical time steps
	spring._lastSchedule = lastUpdateTime
	table.clear(spring._startDisplacements)
	table.clear(spring._startVelocities)
	for index, goal in ipairs(spring._springGoals) do
		spring._startDisplacements[index] = spring._springPositions[index] - goal
		spring._startVelocities[index] = spring._springVelocities[index]
	end

	activeSprings[spring] = true
end

function SpringScheduler.remove(
	spring: InternalTypes.Spring<unknown>
)
	activeSprings[spring] = nil
end

local function updateAllSprings(
	now: number
)
	local springsToSleep: Set<InternalTypes.Spring<unknown>> = {}
	lastUpdateTime = now

	for spring in pairs(activeSprings) do
		local posPos, posVel, velPos, velVel = springCoefficients(
			lastUpdateTime - spring._lastSchedule,
			spring._currentDamping,
			spring._currentSpeed
		)

		local positions = spring._springPositions
		local velocities = spring._springVelocities
		local startDisplacements = spring._startDisplacements
		local startVelocities = spring._startVelocities
		local isMoving = false

		for index, goal in ipairs(spring._springGoals) do
			if goal ~= goal then
				logWarn("springNanGoal")
				continue
			end

			local oldDisplacement = startDisplacements[index]
			local oldVelocity = startVelocities[index]
			local newDisplacement = oldDisplacement * posPos + oldVelocity * posVel
			local newVelocity = oldDisplacement * velPos + oldVelocity * velVel

			if newDisplacement ~= newDisplacement or newVelocity ~= newVelocity then
				logWarn("springNanMotion")
				newDisplacement = 0
				newVelocity = 0
			end

			if math.abs(newDisplacement) > EPSILON or math.abs(newVelocity) > EPSILON then
				isMoving = true
			end

			positions[index] = newDisplacement + goal
			velocities[index] = newVelocity
		end

		if not isMoving then
			springsToSleep[spring] = true
		end
	end

	for spring in pairs(springsToSleep) do
		activeSprings[spring] = nil
		-- Guarantee that springs reach exact goals, since mathematically they only approach it infinitely
		spring._currentValue = packType(spring._springGoals, spring._currentType)
		updateAll(spring)
	end

	for spring in pairs(activeSprings) do
		spring._currentValue = packType(spring._springPositions, spring._currentType)
		updateAll(spring)
	end
end

External.bindToUpdateStep(updateAllSprings)

return SpringScheduler ]]
_c0d361e4644871baf04d173a22202ee8.Children["_b5fe21077e1a3ad6dbb6beea6bc5d048"] = _b5fe21077e1a3ad6dbb6beea6bc5d048
local _b5fe21077e1a3ad6dbb6beea6bc5d048 = nil -- DEALLOCATE PLS :pray:

local _acf68cc2a25ff6a025edc4bf8ce2d9e0 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_acf68cc2a25ff6a025edc4bf8ce2d9e0.Name = "Tween"
_acf68cc2a25ff6a025edc4bf8ce2d9e0.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Constructs a new computed state object, which follows the value of another
	state object using a tween.
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local InternalTypes = require(Package.InternalTypes)
local External = require(Package.External)
local TweenScheduler = require(Package.Animation.TweenScheduler)
local logError = require(Package.Logging.logError)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local isState = require(Package.State.isState)
local peek = require(Package.State.peek)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)
local logWarn = require(Package.Logging.logWarn)

local class = {}
class.type = "State"
class.kind = "Tween"

local CLASS_METATABLE = {__index = class}

--\[\[
	Called when the goal state changes value; this will initiate a new tween.
	Returns false as the current value doesn't change right away.
\]\]
function class:update(): boolean
	local self = self :: InternalTypes.Tween<unknown>
	local goalValue = peek(self._goal)

	-- if the goal hasn't changed, then this is a TweenInfo change.
	-- in that case, if we're not currently animating, we can skip everything
	if goalValue == self._nextValue and not self._currentlyAnimating then
		return false
	end

	local tweenInfo = peek(self._tweenInfo)

	-- if we receive a bad TweenInfo, then error and stop the update
	if typeof(tweenInfo) ~= "TweenInfo" then
		logErrorNonFatal("mistypedTweenInfo", nil, typeof(tweenInfo))
		return false
	end

	self._prevValue = self._currentValue
	self._nextValue = goalValue

	self._currentTweenStartTime = External.lastUpdateStep()
	self._currentTweenInfo = tweenInfo

	local tweenDuration = tweenInfo.DelayTime + tweenInfo.Time
	if tweenInfo.Reverses then
		tweenDuration += tweenInfo.Time
	end
	tweenDuration *= tweenInfo.RepeatCount + 1
	self._currentTweenDuration = tweenDuration

	-- start animating this tween
	TweenScheduler.add(self)

	return false
end

--\[\[
	Returns the interior value of this state object.
\]\]
function class:_peek(): unknown
	local self = self :: InternalTypes.Tween<unknown>
	return self._currentValue
end

function class:get()
	logError("stateGetWasRemoved")
end

function class:destroy()
	local self = self :: InternalTypes.Tween<unknown>
	if self.scope == nil then
		logError("destroyedTwice", nil, "Tween")
	end
	TweenScheduler.remove(self)
	self.scope = nil
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end
end

local function Tween<T>(
	scope: Types.Scope<unknown>,
	goal: Types.UsedAs<T>,
	tweenInfo: Types.UsedAs<TweenInfo>?
): Types.Tween<T>
	if isState(scope) then
		logError("scopeMissing", nil, "Tweens", "myScope:Tween(goalState, tweenInfo)")
	end
	local currentValue = peek(goal)

	-- apply defaults for tween info
	if tweenInfo == nil then
		tweenInfo = TweenInfo.new()
	end

	local dependencySet: {[Types.Dependency]: unknown} = {}

	local goalIsState = isState(goal)
	if goalIsState then
		local goal = goal :: Types.StateObject<T>
		dependencySet[goal] = true
	end

	local tweenInfoIsState = isState(tweenInfo)
	if tweenInfoIsState then
		local tweenInfo = tweenInfo :: Types.StateObject<TweenInfo>
		dependencySet[tweenInfo] = true
	end

	local startingTweenInfo = peek(tweenInfo)
	-- If we start with a bad TweenInfo, then we don't want to construct a Tween
	if typeof(startingTweenInfo) ~= "TweenInfo" then
		logError("mistypedTweenInfo", nil, typeof(startingTweenInfo))
	end

	local self = setmetatable({
		scope = scope,
		dependencySet = dependencySet,
		dependentSet = {},
		_goal = goal,
		_tweenInfo = tweenInfo,
		_tweenInfoIsState = tweenInfoIsState,

		_prevValue = currentValue,
		_nextValue = currentValue,
		_currentValue = currentValue,

		-- store current tween into separately from 'real' tween into, so it
		-- isn't affected by :setTweenInfo() until next change
		_currentTweenInfo = tweenInfo,
		_currentTweenDuration = 0,
		_currentTweenStartTime = 0,
		_currentlyAnimating = false
	}, CLASS_METATABLE)
	local self = (self :: any) :: InternalTypes.Tween<T>

	table.insert(scope, self)
	
	if goalIsState then
		local goal = goal :: any
		if goal.scope == nil then
			logError("useAfterDestroy", nil, `The {goal.kind} object`, `the Tween that is following it`)
		elseif whichLivesLonger(scope, self, goal.scope, goal) == "definitely-a" then
			logWarn("possiblyOutlives", `The {goal.kind} object`, `the Tween that is following it`)
		end
		-- add this object to the goal state's dependent set
		goal.dependentSet[self] = true
	end

	return self
end

return Tween ]]
_c0d361e4644871baf04d173a22202ee8.Children["_acf68cc2a25ff6a025edc4bf8ce2d9e0"] = _acf68cc2a25ff6a025edc4bf8ce2d9e0
local _acf68cc2a25ff6a025edc4bf8ce2d9e0 = nil -- DEALLOCATE PLS :pray:

local _5633ad1663484c890c4a4ca5f2b8df7b = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_5633ad1663484c890c4a4ca5f2b8df7b.Name = "TweenScheduler"
_5633ad1663484c890c4a4ca5f2b8df7b.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Manages batch updating of tween objects.
\]\]

local Package = script.Parent.Parent
local InternalTypes = require(Package.InternalTypes)
local External = require(Package.External)
local lerpType = require(Package.Animation.lerpType)
local getTweenRatio = require(Package.Animation.getTweenRatio)
local updateAll = require(Package.State.updateAll)

local TweenScheduler = {}

type Set<T> = {[T]: unknown}

-- all the tweens currently being updated
local allTweens: Set<InternalTypes.Tween<unknown>> = {}

--\[\[
	Adds a Tween to be updated every render step.
\]\]
function TweenScheduler.add(
	tween: InternalTypes.Tween<unknown>
)
	allTweens[tween] = true
end

--\[\[
	Removes a Tween from the scheduler.
\]\]
function TweenScheduler.remove(
	tween: InternalTypes.Tween<unknown>
)
	allTweens[tween] = nil
end

--\[\[
	Updates all Tween objects.
\]\]
local function updateAllTweens(
	now: number
)
	for tween in allTweens do
		local currentTime = now - tween._currentTweenStartTime

		if currentTime > tween._currentTweenDuration and tween._currentTweenInfo.RepeatCount > -1 then
			if tween._currentTweenInfo.Reverses then
				tween._currentValue = tween._prevValue
			else
				tween._currentValue = tween._nextValue
			end
			tween._currentlyAnimating = false
			updateAll(tween)
			TweenScheduler.remove(tween)
		else
			local ratio = getTweenRatio(tween._currentTweenInfo, currentTime)
			local currentValue = lerpType(tween._prevValue, tween._nextValue, ratio)
			tween._currentValue = currentValue
			tween._currentlyAnimating = true
			updateAll(tween)
		end
	end
end

External.bindToUpdateStep(updateAllTweens)

return TweenScheduler ]]
_c0d361e4644871baf04d173a22202ee8.Children["_5633ad1663484c890c4a4ca5f2b8df7b"] = _5633ad1663484c890c4a4ca5f2b8df7b
local _5633ad1663484c890c4a4ca5f2b8df7b = nil -- DEALLOCATE PLS :pray:

local _1c7842d0abd6a3ea39358dd7ae24a65f = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_1c7842d0abd6a3ea39358dd7ae24a65f.Name = "getTweenRatio"
_1c7842d0abd6a3ea39358dd7ae24a65f.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Given a `tweenInfo` and `currentTime`, returns a ratio which can be used to
	tween between two values over time.
\]\]

local TweenService = game:GetService("TweenService")

local function getTweenRatio(
	tweenInfo: TweenInfo,
	currentTime: number
): number
	local delay = tweenInfo.DelayTime
	local duration = tweenInfo.Time
	local reverses = tweenInfo.Reverses
	local numCycles = 1 + tweenInfo.RepeatCount
	local easeStyle = tweenInfo.EasingStyle
	local easeDirection = tweenInfo.EasingDirection

	local cycleDuration = delay + duration
	if reverses then
		cycleDuration += duration
	end

	if currentTime >= cycleDuration * numCycles and tweenInfo.RepeatCount > -1 then
		return 1
	end

	local cycleTime = currentTime % cycleDuration

	if cycleTime <= delay then
		return 0
	end

	local tweenProgress = (cycleTime - delay) / duration
	if tweenProgress > 1 then
		tweenProgress = 2 - tweenProgress
	end

	local ratio = TweenService:GetValue(tweenProgress, easeStyle, easeDirection)
	return ratio
end

return getTweenRatio ]]
_c0d361e4644871baf04d173a22202ee8.Children["_1c7842d0abd6a3ea39358dd7ae24a65f"] = _1c7842d0abd6a3ea39358dd7ae24a65f
local _1c7842d0abd6a3ea39358dd7ae24a65f = nil -- DEALLOCATE PLS :pray:

local _1da1f3f54dc86a890ab9366a551c32a0 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_1da1f3f54dc86a890ab9366a551c32a0.Name = "lerpType"
_1da1f3f54dc86a890ab9366a551c32a0.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Linearly interpolates the given animatable types by a ratio.
	If the types are different or not animatable, then the first value will be
	returned for ratios below 0.5, and the second value for 0.5 and above.
\]\]

local Package = script.Parent.Parent
local Oklab = require(Package.Colour.Oklab)

local function lerpType(
	from: unknown, 
	to: unknown, 
	ratio: number
): unknown
	local typeString = typeof(from)

	if typeof(to) == typeString then
		-- both types must match for interpolation to make sense
		if typeString == "number" then
			local to, from = to :: number, from :: number
			return (to - from) * ratio + from

		elseif typeString == "CFrame" then
			local to, from = to :: CFrame, from :: CFrame
			return from:Lerp(to, ratio)

		elseif typeString == "Color3" then
			local to, from = to :: Color3, from :: Color3
			local fromLab = Oklab.fromSRGB(from)
			local toLab = Oklab.fromSRGB(to)
			return Oklab.toSRGB(
				fromLab:Lerp(toLab, ratio),
				false
			)

		elseif typeString == "ColorSequenceKeypoint" then
			local to, from = to :: ColorSequenceKeypoint, from :: ColorSequenceKeypoint
			local fromLab = Oklab.fromSRGB(from.Value)
			local toLab = Oklab.fromSRGB(to.Value)
			return ColorSequenceKeypoint.new(
				(to.Time - from.Time) * ratio + from.Time,
				Oklab.toSRGB(
					fromLab:Lerp(toLab, ratio),
					false
				)
			)

		elseif typeString == "DateTime" then
			local to, from = to :: DateTime, from :: DateTime
			return DateTime.fromUnixTimestampMillis(
				(to.UnixTimestampMillis - from.UnixTimestampMillis) * ratio + from.UnixTimestampMillis
			)

		elseif typeString == "NumberRange" then
			local to, from = to :: NumberRange, from :: NumberRange
			return NumberRange.new(
				(to.Min - from.Min) * ratio + from.Min,
				(to.Max - from.Max) * ratio + from.Max
			)

		elseif typeString == "NumberSequenceKeypoint" then
			local to, from = to :: NumberSequenceKeypoint, from :: NumberSequenceKeypoint
			return NumberSequenceKeypoint.new(
				(to.Time - from.Time) * ratio + from.Time,
				(to.Value - from.Value) * ratio + from.Value,
				(to.Envelope - from.Envelope) * ratio + from.Envelope
			)

		elseif typeString == "PhysicalProperties" then
			local to, from = to :: PhysicalProperties, from :: PhysicalProperties
			return PhysicalProperties.new(
				(to.Density - from.Density) * ratio + from.Density,
				(to.Friction - from.Friction) * ratio + from.Friction,
				(to.Elasticity - from.Elasticity) * ratio + from.Elasticity,
				(to.FrictionWeight - from.FrictionWeight) * ratio + from.FrictionWeight,
				(to.ElasticityWeight - from.ElasticityWeight) * ratio + from.ElasticityWeight
			)

		elseif typeString == "Ray" then
			local to, from = to :: Ray, from :: Ray
			return Ray.new(
				from.Origin:Lerp(to.Origin, ratio),
				from.Direction:Lerp(to.Direction, ratio)
			)

		elseif typeString == "Rect" then
			local to, from = to :: Rect, from :: Rect
			return Rect.new(
				from.Min:Lerp(to.Min, ratio),
				from.Max:Lerp(to.Max, ratio)
			)

		elseif typeString == "Region3" then
			local to, from = to :: Region3, from :: Region3
			-- FUTURE: support rotated Region3s if/when they become constructable
			local position = from.CFrame.Position:Lerp(to.CFrame.Position, ratio)
			local halfSize = from.Size:Lerp(to.Size, ratio) / 2
			return Region3.new(position - halfSize, position + halfSize)

		elseif typeString == "Region3int16" then
			local to, from = to :: Region3int16, from :: Region3int16
			return Region3int16.new(
				Vector3int16.new(
					(to.Min.X - from.Min.X) * ratio + from.Min.X,
					(to.Min.Y - from.Min.Y) * ratio + from.Min.Y,
					(to.Min.Z - from.Min.Z) * ratio + from.Min.Z
				),
				Vector3int16.new(
					(to.Max.X - from.Max.X) * ratio + from.Max.X,
					(to.Max.Y - from.Max.Y) * ratio + from.Max.Y,
					(to.Max.Z - from.Max.Z) * ratio + from.Max.Z
				)
			)

		elseif typeString == "UDim" then
			local to, from = to :: UDim, from :: UDim
			return UDim.new(
				(to.Scale - from.Scale) * ratio + from.Scale,
				(to.Offset - from.Offset) * ratio + from.Offset
			)

		elseif typeString == "UDim2" then
			local to, from = to :: UDim2, from :: UDim2
			return from:Lerp(to, ratio)

		elseif typeString == "Vector2" then
			local to, from = to :: Vector2, from :: Vector2
			return from:Lerp(to, ratio)

		elseif typeString == "Vector2int16" then
			local to, from = to :: Vector2int16, from :: Vector2int16
			return Vector2int16.new(
				(to.X - from.X) * ratio + from.X,
				(to.Y - from.Y) * ratio + from.Y
			)

		elseif typeString == "Vector3" then
			local to, from = to :: Vector3, from :: Vector3
			return from:Lerp(to, ratio)

		elseif typeString == "Vector3int16" then
			local to, from = to :: Vector3int16, from :: Vector3int16
			return Vector3int16.new(
				(to.X - from.X) * ratio + from.X,
				(to.Y - from.Y) * ratio + from.Y,
				(to.Z - from.Z) * ratio + from.Z
			)
		end
	end

	-- fallback case: the types are different or not animatable
	if ratio < 0.5 then
		return from
	else
		return to
	end
end

return lerpType ]]
_c0d361e4644871baf04d173a22202ee8.Children["_1da1f3f54dc86a890ab9366a551c32a0"] = _1da1f3f54dc86a890ab9366a551c32a0
local _1da1f3f54dc86a890ab9366a551c32a0 = nil -- DEALLOCATE PLS :pray:

local _2af5db9c45410769af07c0009a6cd2b5 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_2af5db9c45410769af07c0009a6cd2b5.Name = "packType"
_2af5db9c45410769af07c0009a6cd2b5.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Packs an array of numbers into a given animatable data type.
	If the type is not animatable, nil will be returned.
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local Oklab = require(Package.Colour.Oklab)

local function packType(
	numbers: {number},
	typeString: string
): Types.Animatable?
	if typeString == "number" then
		return numbers[1]

	elseif typeString == "CFrame" then
		return
			CFrame.new(numbers[1], numbers[2], numbers[3]) *
			CFrame.fromAxisAngle(
				Vector3.new(numbers[4], numbers[5], numbers[6]).Unit,
				numbers[7]
			)

	elseif typeString == "Color3" then
		return Oklab.toSRGB(
			Vector3.new(numbers[1], numbers[2], numbers[3]),
			false
		)

	elseif typeString == "ColorSequenceKeypoint" then
		return ColorSequenceKeypoint.new(
			numbers[4],
			Oklab.toSRGB(
				Vector3.new(numbers[1], numbers[2], numbers[3]),
				false
			)
		)

	elseif typeString == "DateTime" then
		return DateTime.fromUnixTimestampMillis(numbers[1])

	elseif typeString == "NumberRange" then
		return NumberRange.new(numbers[1], numbers[2])

	elseif typeString == "NumberSequenceKeypoint" then
		return NumberSequenceKeypoint.new(numbers[2], numbers[1], numbers[3])

	elseif typeString == "PhysicalProperties" then
		return PhysicalProperties.new(numbers[1], numbers[2], numbers[3], numbers[4], numbers[5])

	elseif typeString == "Ray" then
		return Ray.new(
			Vector3.new(numbers[1], numbers[2], numbers[3]),
			Vector3.new(numbers[4], numbers[5], numbers[6])
		)

	elseif typeString == "Rect" then
		return Rect.new(numbers[1], numbers[2], numbers[3], numbers[4])

	elseif typeString == "Region3" then
		-- FUTURE: support rotated Region3s if/when they become constructable
		local position = Vector3.new(numbers[1], numbers[2], numbers[3])
		local halfSize = Vector3.new(numbers[4] / 2, numbers[5] / 2, numbers[6] / 2)
		return Region3.new(position - halfSize, position + halfSize)

	elseif typeString == "Region3int16" then
		return Region3int16.new(
			Vector3int16.new(numbers[1], numbers[2], numbers[3]),
			Vector3int16.new(numbers[4], numbers[5], numbers[6])
		)

	elseif typeString == "UDim" then
		return UDim.new(numbers[1], numbers[2])

	elseif typeString == "UDim2" then
		return UDim2.new(numbers[1], numbers[2], numbers[3], numbers[4])

	elseif typeString == "Vector2" then
		return Vector2.new(numbers[1], numbers[2])

	elseif typeString == "Vector2int16" then
		return Vector2int16.new(numbers[1], numbers[2])

	elseif typeString == "Vector3" then
		return Vector3.new(numbers[1], numbers[2], numbers[3])

	elseif typeString == "Vector3int16" then
		return Vector3int16.new(numbers[1], numbers[2], numbers[3])
	else
		return nil
	end
end

return packType ]]
_c0d361e4644871baf04d173a22202ee8.Children["_2af5db9c45410769af07c0009a6cd2b5"] = _2af5db9c45410769af07c0009a6cd2b5
local _2af5db9c45410769af07c0009a6cd2b5 = nil -- DEALLOCATE PLS :pray:

local _e58478cab4152d69d9887803d9e1422a = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_e58478cab4152d69d9887803d9e1422a.Name = "springCoefficients"
_e58478cab4152d69d9887803d9e1422a.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Returns a 2x2 matrix of coefficients for a given time, damping and speed.
	Specifically, this returns four coefficients - posPos, posVel, velPos, and
	velVel - which can be multiplied with position and velocity like so:

	local newPosition = oldPosition * posPos + oldVelocity * posVel
	local newVelocity = oldPosition * velPos + oldVelocity * velVel

	Special thanks to AxisAngle for helping to improve numerical precision.
\]\]

local function springCoefficients(
	time: number,
	damping: number,
	speed: number
): (number, number, number, number)
	-- if time or speed is 0, then the spring won't move
	if time == 0 or speed == 0 then
		return 1, 0, 0, 1
	end
	local posPos, posVel, velPos, velVel

	if damping > 1 then
		-- overdamped spring
		-- solution to the characteristic equation:
		-- z = -ζω ± Sqrt[ζ^2 - 1] ω
		-- x[t] -> x0(e^(t z2) z1 - e^(t z1) z2)/(z1 - z2)
		--		 + v0(e^(t z1) - e^(t z2))/(z1 - z2)
		-- v[t] -> x0(z1 z2(-e^(t z1) + e^(t z2)))/(z1 - z2)
		--		 + v0(z1 e^(t z1) - z2 e^(t z2))/(z1 - z2)

		local scaledTime = time * speed
		local alpha = math.sqrt(damping^2 - 1)
		local scaledInvAlpha = -0.5 / alpha
		local z1 = -alpha - damping
		local z2 = 1 / z1
		local expZ1 = math.exp(scaledTime * z1)
		local expZ2 = math.exp(scaledTime * z2)

		posPos = (expZ2*z1 - expZ1*z2) * scaledInvAlpha
		posVel = (expZ1 - expZ2) * scaledInvAlpha / speed
		velPos = (expZ2 - expZ1) * scaledInvAlpha * speed
		velVel = (expZ1*z1 - expZ2*z2) * scaledInvAlpha

	elseif damping == 1 then
		-- critically damped spring
		-- x[t] -> x0(e^-tω)(1+tω) + v0(e^-tω)t
		-- v[t] -> x0(t ω^2)(-e^-tω) + v0(1 - tω)(e^-tω)

		local scaledTime = time * speed
		local expTerm = math.exp(-scaledTime)

		posPos = expTerm * (1 + scaledTime)
		posVel = expTerm * time
		velPos = expTerm * (-scaledTime*speed)
		velVel = expTerm * (1 - scaledTime)

	else
		-- underdamped spring
		-- factored out of the solutions to the characteristic equation:
		-- α = Sqrt[1 - ζ^2]
		-- x[t] -> x0(e^-tζω)(α Cos[tα] + ζω Sin[tα])/α
		--       + v0(e^-tζω)(Sin[tα])/α
		-- v[t] -> x0(-e^-tζω)(α^2 + ζ^2 ω^2)(Sin[tα])/α
		--       + v0(e^-tζω)(α Cos[tα] - ζω Sin[tα])/α

		local scaledTime = time * speed
		local alpha = math.sqrt(1 - damping^2)
		local invAlpha = 1 / alpha
		local alphaTime = alpha * scaledTime
		local expTerm = math.exp(-scaledTime*damping)
		local sinTerm = expTerm * math.sin(alphaTime)
		local cosTerm = expTerm * math.cos(alphaTime)
		local sinInvAlpha = sinTerm*invAlpha
		local sinInvAlphaDamp = sinInvAlpha*damping

		posPos = sinInvAlphaDamp + cosTerm
		posVel = sinInvAlpha
		velPos = -(sinInvAlphaDamp*damping + sinTerm*alpha)
		velVel = cosTerm - sinInvAlphaDamp
	end

	return posPos, posVel, velPos, velVel
end

return springCoefficients ]]
_c0d361e4644871baf04d173a22202ee8.Children["_e58478cab4152d69d9887803d9e1422a"] = _e58478cab4152d69d9887803d9e1422a
local _e58478cab4152d69d9887803d9e1422a = nil -- DEALLOCATE PLS :pray:

local _7333fbe4cfcc08c5ac7177cfcda5cd14 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_7333fbe4cfcc08c5ac7177cfcda5cd14.Name = "unpackType"
_7333fbe4cfcc08c5ac7177cfcda5cd14.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Unpacks an animatable type into an array of numbers.
	If the type is not animatable, an empty array will be returned.
\]\]

local Package = script.Parent.Parent
local Oklab = require(Package.Colour.Oklab)

local function unpackType(
	value: unknown,
	typeString: string
): {number}
	if typeString == "number" then
		local value = value :: number
		return {value}

	elseif typeString == "CFrame" then
		local value = value :: CFrame
		-- FUTURE: is there a better way of doing this? doing distance
		-- calculations on `angle` may be incorrect
		local axis, angle = value:ToAxisAngle()
		return {value.X, value.Y, value.Z, axis.X, axis.Y, axis.Z, angle}

	elseif typeString == "Color3" then
		local value = value :: Color3
		local lab = Oklab.fromSRGB(value)
		return {lab.X, lab.Y, lab.Z}

	elseif typeString == "ColorSequenceKeypoint" then
		local value = value :: ColorSequenceKeypoint
		local lab = Oklab.fromSRGB(value.Value)
		return {lab.X, lab.Y, lab.Z, value.Time}

	elseif typeString == "DateTime" then
		local value = value :: DateTime
		return {value.UnixTimestampMillis}

	elseif typeString == "NumberRange" then
		local value = value :: NumberRange
		return {value.Min, value.Max}

	elseif typeString == "NumberSequenceKeypoint" then
		local value = value :: NumberSequenceKeypoint
		return {value.Value, value.Time, value.Envelope}

	elseif typeString == "PhysicalProperties" then
		local value = value :: PhysicalProperties
		return {value.Density, value.Friction, value.Elasticity, value.FrictionWeight, value.ElasticityWeight}

	elseif typeString == "Ray" then
		local value = value :: Ray
		return {value.Origin.X, value.Origin.Y, value.Origin.Z, value.Direction.X, value.Direction.Y, value.Direction.Z}

	elseif typeString == "Rect" then
		local value = value :: Rect
		return {value.Min.X, value.Min.Y, value.Max.X, value.Max.Y}

	elseif typeString == "Region3" then
		local value = value :: Region3
		-- FUTURE: support rotated Region3s if/when they become constructable
		return {
			value.CFrame.X, value.CFrame.Y, value.CFrame.Z,
			value.Size.X, value.Size.Y, value.Size.Z
		}

	elseif typeString == "Region3int16" then
		local value = value :: Region3int16
		return {value.Min.X, value.Min.Y, value.Min.Z, value.Max.X, value.Max.Y, value.Max.Z}

	elseif typeString == "UDim" then
		local value = value :: UDim
		return {value.Scale, value.Offset}

	elseif typeString == "UDim2" then
		local value = value :: UDim2
		return {value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset}

	elseif typeString == "Vector2" then
		local value = value :: Vector2
		return {value.X, value.Y}

	elseif typeString == "Vector2int16" then
		local value = value :: Vector2int16
		return {value.X, value.Y}

	elseif typeString == "Vector3" then
		local value = value :: Vector3
		return {value.X, value.Y, value.Z}

	elseif typeString == "Vector3int16" then
		local value = value :: Vector3int16
		return {value.X, value.Y, value.Z}
	else
		return {}
	end
end

return unpackType ]]
_c0d361e4644871baf04d173a22202ee8.Children["_7333fbe4cfcc08c5ac7177cfcda5cd14"] = _7333fbe4cfcc08c5ac7177cfcda5cd14
local _7333fbe4cfcc08c5ac7177cfcda5cd14 = nil -- DEALLOCATE PLS :pray:

local _2f858aadbe1ef588e837541ae6a652d1 = { ClassName = "Folder", Children = {}, Properties = {} }
_2f858aadbe1ef588e837541ae6a652d1.Name = "Colour"
_d56864cbc3c61714243504ffab872304.Children["_2f858aadbe1ef588e837541ae6a652d1"] = _2f858aadbe1ef588e837541ae6a652d1
local _2f858aadbe1ef588e837541ae6a652d1 = nil -- DEALLOCATE PLS :pray:
local _c18812a3e21ffb32ca456d755d6a3224 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_c18812a3e21ffb32ca456d755d6a3224.Name = "Oklab"
_c18812a3e21ffb32ca456d755d6a3224.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Provides functions for converting Color3s into Oklab space, for more
	perceptually uniform colour blending.

	See: https://bottosson.github.io/posts/oklab/
\]\]

local sRGB = require(script.Parent.sRGB)

local Oklab = {}

-- Converts a Color3 in linear RGB space to a Vector3 in Oklab space.
function Oklab.fromLinear(rgb: Color3): Vector3

	local l = rgb.R * 0.4122214708 + rgb.G * 0.5363325363 + rgb.B * 0.0514459929
	local m = rgb.R * 0.2119034982 + rgb.G * 0.6806995451 + rgb.B * 0.1073969566
	local s = rgb.R * 0.0883024619 + rgb.G * 0.2817188376 + rgb.B * 0.6299787005

	local lRoot = l ^ (1/3)
	local mRoot = m ^ (1/3)
	local sRoot = s ^ (1/3)

	return Vector3.new(
		lRoot * 0.2104542553 + mRoot * 0.7936177850 - sRoot * 0.0040720468,
		lRoot * 1.9779984951 - mRoot * 2.4285922050 + sRoot * 0.4505937099,
		lRoot * 0.0259040371 + mRoot * 0.7827717662 - sRoot * 0.8086757660
	)
end

-- Converts a Color3 in sRGB space to a Vector3 in Oklab space.
function Oklab.fromSRGB(srgb: Color3): Vector3
	return Oklab.fromLinear(sRGB.toLinear(srgb))
end

-- Converts a Vector3 in Oklab space to a Color3 in linear RGB space.
-- The Color3 will be clamped by default unless specified otherwise.
function Oklab.toLinear(lab: Vector3, unclamped: boolean?): Color3
	local lRoot = lab.X + lab.Y * 0.3963377774 + lab.Z * 0.2158037573
	local mRoot = lab.X - lab.Y * 0.1055613458 - lab.Z * 0.0638541728
	local sRoot = lab.X - lab.Y * 0.0894841775 - lab.Z * 1.2914855480

	local l = lRoot ^ 3
	local m = mRoot ^ 3
	local s = sRoot ^ 3

	local red = l * 4.0767416621 - m * 3.3077115913 + s * 0.2309699292
	local green = l * -1.2684380046 + m * 2.6097574011 - s * 0.3413193965
	local blue = l * -0.0041960863 - m * 0.7034186147 + s * 1.7076147010

	if not unclamped then
		red = math.clamp(red, 0, 1)
		green = math.clamp(green, 0, 1)
		blue = math.clamp(blue, 0, 1)
	end

	return Color3.new(red, green, blue)
end

-- Converts a Vector3 in Oklab space to a Color3 in sRGB space.
-- The Color3 will be clamped by default unless specified otherwise.
function Oklab.toSRGB(lab: Vector3, unclamped: boolean?): Color3
	return sRGB.fromLinear(Oklab.toLinear(lab, unclamped))
end

return Oklab ]]
_2f858aadbe1ef588e837541ae6a652d1.Children["_c18812a3e21ffb32ca456d755d6a3224"] = _c18812a3e21ffb32ca456d755d6a3224
local _c18812a3e21ffb32ca456d755d6a3224 = nil -- DEALLOCATE PLS :pray:

local _c15efb62de0afca67a5f917f4b48227d = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_c15efb62de0afca67a5f917f4b48227d.Name = "sRGB"
_c15efb62de0afca67a5f917f4b48227d.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
    Provides transformation functions for converting linear RGB values
    into sRGB values.

    RGB color channel transformations are outlined here:
    https://bottosson.github.io/posts/colorwrong/#what-can-we-do%3F
\]\]

local sRGB = {}

-- Equivalent to f_inv. Takes a linear sRGB channel and returns
-- the sRGB channel
local function transform(channel: number): number
    if channel >= 0.04045 then
        return ((channel + 0.055)/(1 + 0.055))^2.4
    else
        return channel / 12.92
    end
end

-- Equivalent to f. Takes an sRGB channel and returns
-- the linear sRGB channel
local function inverse(channel: number): number
    if channel >= 0.0031308 then
        return (1.055) * channel^(1.0/2.4) - 0.055
    else
        return 12.92 * channel
    end
end

-- Uses a tranformation to convert linear RGB into sRGB.
function sRGB.fromLinear(rgb: Color3): Color3
    return Color3.new(
        transform(rgb.R),
        transform(rgb.G),
        transform(rgb.B)
    )
end

-- Converts an sRGB into linear RGB using a
-- (The inverse of sRGB.fromLinear).
function sRGB.toLinear(srgb: Color3): Color3
    return Color3.new(
        inverse(srgb.R),
        inverse(srgb.G),
        inverse(srgb.B)
    )
end

return sRGB ]]
_2f858aadbe1ef588e837541ae6a652d1.Children["_c15efb62de0afca67a5f917f4b48227d"] = _c15efb62de0afca67a5f917f4b48227d
local _c15efb62de0afca67a5f917f4b48227d = nil -- DEALLOCATE PLS :pray:

local _456fc8cb77d4bbadb9d6c52dc951c387 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_456fc8cb77d4bbadb9d6c52dc951c387.Name = "External"
_456fc8cb77d4bbadb9d6c52dc951c387.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Abstraction layer between Fusion internals and external environments,
	allowing for flexible integration with schedulers and test mocks.
\]\]

local Package = script.Parent
local logError = require(Package.Logging.logError)

local External = {}

export type Scheduler = {
	doTaskImmediate: (
		resume: () -> ()
	) -> (),
	doTaskDeferred: (
		resume: () -> ()
	) -> (),
	errorNonFatal: (
		err: unknown
	) -> (),
	startScheduler: () -> (),
	stopScheduler: () -> ()
}

local updateStepCallbacks = {}
local currentScheduler: Scheduler? = nil
local lastUpdateStep = 0

--\[\[
	Sets the external scheduler that Fusion will use for queuing async tasks.
	Returns the previous scheduler so it can be reset later.
\]\]
function External.setExternalScheduler(
	newScheduler: Scheduler?
): Scheduler?
	local oldScheduler = currentScheduler
	if oldScheduler ~= nil then
		oldScheduler.stopScheduler()
	end
	currentScheduler = newScheduler
	if newScheduler ~= nil then
		newScheduler.startScheduler()
	end
	return oldScheduler
end

--\[\[
   Sends an immediate task to the external scheduler. Throws if none is set.
\]\]
function External.doTaskImmediate(
	resume: () -> ()
)
	if currentScheduler == nil then
		logError("noTaskScheduler")
	else
		currentScheduler.doTaskImmediate(resume)
	end
end

--\[\[
	Sends a deferred task to the external scheduler. Throws if none is set.
\]\]
function External.doTaskDeferred(
	resume: () -> ()
)
	if currentScheduler == nil then
		logError("noTaskScheduler")
	else
		currentScheduler.doTaskDeferred(resume)
	end
end

--\[\[
	Errors in a different thread to preserve the flow of execution.
\]\]
function External.errorNonFatal(
	err: unknown
)
	if currentScheduler == nil then
		logError("noTaskScheduler")
	else
		currentScheduler.errorNonFatal(err)
	end
end

--\[\[
	Registers a callback to the update step of the external scheduler.
	Returns a function that can be used to disconnect later.

	Callbacks are given the current number of seconds since an arbitrary epoch.
	
	TODO: This epoch may change between schedulers. We could investigate ways
	of allowing schedulers to co-operate to keep the epoch the same, so that
	monotonicity can be better preserved.
\]\]
function External.bindToUpdateStep(
	callback: (
		now: number
	) -> ()
): () -> ()
	local uniqueIdentifier = {}
	updateStepCallbacks[uniqueIdentifier] = callback
	return function()
		updateStepCallbacks[uniqueIdentifier] = nil
	end
end

--\[\[
	Steps time-dependent systems with the current number of seconds since an
	arbitrary epoch. This should be called as early as possible in the external
	scheduler's update cycle.
\]\]
function External.performUpdateStep(
	now: number
)
	lastUpdateStep = now
	for _, callback in updateStepCallbacks do
		callback(now)
	end
end

--\[\[
	Returns the timestamp of the last update step.
\]\]
function External.lastUpdateStep()
	return lastUpdateStep
end

return External ]]
_d56864cbc3c61714243504ffab872304.Children["_456fc8cb77d4bbadb9d6c52dc951c387"] = _456fc8cb77d4bbadb9d6c52dc951c387
local _456fc8cb77d4bbadb9d6c52dc951c387 = nil -- DEALLOCATE PLS :pray:

local _57f0a784b6878581c404cdc080a3057d = { ClassName = "Folder", Children = {}, Properties = {} }
_57f0a784b6878581c404cdc080a3057d.Name = "Instances"
_d56864cbc3c61714243504ffab872304.Children["_57f0a784b6878581c404cdc080a3057d"] = _57f0a784b6878581c404cdc080a3057d
local _57f0a784b6878581c404cdc080a3057d = nil -- DEALLOCATE PLS :pray:
local _85859ee5d817c5eada7b354f52f3e4b6 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_85859ee5d817c5eada7b354f52f3e4b6.Name = "Attribute"
_85859ee5d817c5eada7b354f52f3e4b6.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	A special key for property tables, which allows users to apply custom
	attributes to instances
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local logError = require(Package.Logging.logError)
local logWarn = require(Package.Logging.logWarn)
local isState = require(Package.State.isState)
local Observer = require(Package.State.Observer)
local peek = require(Package.State.peek)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)

local keyCache: {[string]: Types.SpecialKey} = {}

local function Attribute(
	attributeName: string
): Types.SpecialKey
	local key = keyCache[attributeName]
	if key == nil then
		key = {
			type = "SpecialKey",
			kind = "Attribute",
			stage = "self",
			apply = function(
				self: Types.SpecialKey,
				scope: Types.Scope<unknown>,
				value: unknown,
				applyTo: Instance
			)
				if isState(value) then
					local value = value :: Types.StateObject<unknown>
					if value.scope == nil then
						logError("useAfterDestroy", nil, `The {value.kind} object, bound to [Attribute "{attributeName}"],`, `the {applyTo.ClassName} instance`)
					elseif whichLivesLonger(scope, applyTo, value.scope, value) == "definitely-a" then
						logWarn("possiblyOutlives", `The {value.kind} object, bound to [Attribute "{attributeName}"],`, `the {applyTo.ClassName} instance`)
					end
					Observer(scope, value :: any):onBind(function()
						applyTo:SetAttribute(attributeName, peek(value))
					end)
				else
					applyTo:SetAttribute(attributeName, value)
				end
			end
		}
		keyCache[attributeName] = key
	end
	return key
end

return Attribute ]]
_57f0a784b6878581c404cdc080a3057d.Children["_85859ee5d817c5eada7b354f52f3e4b6"] = _85859ee5d817c5eada7b354f52f3e4b6
local _85859ee5d817c5eada7b354f52f3e4b6 = nil -- DEALLOCATE PLS :pray:

local _8b82b1ee2abb7eb220dfcb94a98d5fb8 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_8b82b1ee2abb7eb220dfcb94a98d5fb8.Name = "AttributeChange"
_8b82b1ee2abb7eb220dfcb94a98d5fb8.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	A special key for property tables, which allows users to connect to
	an attribute change on an instance.
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local logError = require(Package.Logging.logError)

local keyCache: {[string]: Types.SpecialKey} = {}

local function AttributeChange(
	attributeName: string
): Types.SpecialKey
	local key = keyCache[attributeName]
	if key == nil then
		key = {
			type = "SpecialKey",
			kind = "AttributeChange",
			stage = "observer",
			apply = function(
				self: Types.SpecialKey,
				scope: Types.Scope<unknown>,
				value: unknown,
				applyTo: Instance
			)
				if typeof(value) ~= "function" then
					logError("invalidAttributeChangeHandler", nil, attributeName)
				end
				local value = value :: (...unknown) -> (...unknown)
				local event = applyTo:GetAttributeChangedSignal(attributeName)
				table.insert(scope, event:Connect(function()
					value((applyTo :: any):GetAttribute(attributeName))
				end))
			end
		}
		keyCache[attributeName] = key
	end
	return key
end

return AttributeChange ]]
_57f0a784b6878581c404cdc080a3057d.Children["_8b82b1ee2abb7eb220dfcb94a98d5fb8"] = _8b82b1ee2abb7eb220dfcb94a98d5fb8
local _8b82b1ee2abb7eb220dfcb94a98d5fb8 = nil -- DEALLOCATE PLS :pray:

local _531059633766115f9da3f62f1bf88067 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_531059633766115f9da3f62f1bf88067.Name = "AttributeOut"
_531059633766115f9da3f62f1bf88067.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	A special key for property tables, which allows users to save instance attributes
	into state objects
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local logError = require(Package.Logging.logError)
local logWarn = require(Package.Logging.logWarn)
local isState = require(Package.State.isState)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)

local keyCache: {[string]: Types.SpecialKey} = {}

local function AttributeOut(
	attributeName: string
): Types.SpecialKey
	local key = keyCache[attributeName]
	if key == nil then
		key = {
			type = "SpecialKey",
			kind = "AttributeOut",
			stage = "observer",
			apply = function(
				self: Types.SpecialKey,
				scope: Types.Scope<unknown>,
				value: unknown,
				applyTo: Instance
			)
				local event = applyTo:GetAttributeChangedSignal(attributeName)
	
				if not isState(value) then
					logError("invalidAttributeOutType")
				end
				local value = value :: Types.StateObject<unknown>
				if value.kind ~= "Value" then
					logError("invalidAttributeOutType")
				end
				local value = value :: Types.Value<unknown>
				
				if value.scope == nil then
					logError("useAfterDestroy", nil, `The Value object, which [AttributeOut "{attributeName}"] outputs to,`, `the {applyTo.ClassName} instance`)
				elseif whichLivesLonger(scope, applyTo, value.scope, value) == "definitely-a" then
					logWarn("possiblyOutlives", `The Value object, which [AttributeOut "{attributeName}"] outputs to,`, `the {applyTo.ClassName} instance`)
				end
				value:set((applyTo :: any):GetAttribute(attributeName))
				table.insert(scope, event:Connect(function()	
					value:set((applyTo :: any):GetAttribute(attributeName))
				end))
			end
		}
		keyCache[attributeName] = key
	end
	return key
end

return AttributeOut ]]
_57f0a784b6878581c404cdc080a3057d.Children["_531059633766115f9da3f62f1bf88067"] = _531059633766115f9da3f62f1bf88067
local _531059633766115f9da3f62f1bf88067 = nil -- DEALLOCATE PLS :pray:

local _583ba759b934dc5c5b06b333e50a89ae = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_583ba759b934dc5c5b06b333e50a89ae.Name = "Children"
_583ba759b934dc5c5b06b333e50a89ae.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	A special key for property tables, which parents any given descendants into
	an instance.
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local logWarn = require(Package.Logging.logWarn)
local Observer = require(Package.State.Observer)
local peek = require(Package.State.peek)
local isState = require(Package.State.isState)
local doCleanup = require(Package.Memory.doCleanup)
local scopePool = require(Package.Memory.scopePool)

type Set<T> = {[T]: unknown}

-- Experimental flag: name children based on the key used in the [Children] table
local EXPERIMENTAL_AUTO_NAMING = false

return {
	type = "SpecialKey",
	kind = "Children",
	stage = "descendants",
	apply = function(
		self: Types.SpecialKey,
		scope: Types.Scope<unknown>,
		value: unknown,
		applyTo: Instance
	)
		local newParented: Set<Instance> = {}
		local oldParented: Set<Instance> = {}
	
		-- save scopes for state object observers
		local newScopes: {[Types.StateObject<unknown>]: Types.Scope<unknown>} = {}
		local oldScopes: {[Types.StateObject<unknown>]: Types.Scope<unknown>} = {}
	
		-- Rescans this key's value to find new instances to parent and state objects
		-- to observe for changes; then unparents instances no longer found and
		-- disconnects observers for state objects no longer present.
		local function updateChildren()
			oldParented, newParented = newParented, oldParented
			oldScopes, newScopes = newScopes, oldScopes
			table.clear(newParented)
			table.clear(newScopes)
	
			local function processChild(
				child: unknown,
				autoName: string?
			)
				local childType = typeof(child)
	
				if childType == "Instance" then
					-- case 1; single instance
					local child = child :: Instance
	
					newParented[child] = true
					if oldParented[child] == nil then
						-- wasn't previously present
	
						-- TODO: check for ancestry conflicts here
						child.Parent = applyTo
					else
						-- previously here; we want to reuse, so remove from old
						-- set so we don't encounter it during unparenting
						oldParented[child] = nil
					end
	
					if EXPERIMENTAL_AUTO_NAMING and autoName ~= nil then
						child.Name = autoName
					end
	
				elseif isState(child) then
					-- case 2; state object
					local child = child :: Types.StateObject<unknown>
	
					local value = peek(child)
					-- allow nil to represent the absence of a child
					if value ~= nil then
						processChild(value, autoName)
					end
	
					local childScope = oldScopes[child]
					if childScope == nil then
						-- wasn't previously present
						childScope = {}
						Observer(childScope, child):onChange(updateChildren)
					else
						-- previously here; we want to reuse, so remove from old
						-- set so we don't encounter it during unparenting
						oldScopes[child] = nil
					end
	
					newScopes[child] = childScope
	
				elseif childType == "table" then
					-- case 3; table of objects
					local child = child :: {[unknown]: unknown}
	
					for key, subChild in pairs(child) do
						local keyType = typeof(key)
						local subAutoName: string? = nil
	
						if keyType == "string" then
							local key = key :: string
							subAutoName = key
						elseif keyType == "number" and autoName ~= nil then
							local key = key :: number
							subAutoName = autoName .. "_" .. key
						end
	
						processChild(subChild, subAutoName)
					end
	
				else
					logWarn("unrecognisedChildType", childType)
				end
			end
	
			if value ~= nil then
				-- `propValue` is set to nil on cleanup, so we don't process children
				-- in that case
				processChild(value)
			end
	
			-- unparent any children that are no longer present
			for oldInstance in pairs(oldParented) do
				oldInstance.Parent = nil
			end
	
			-- disconnect observers which weren't reused
			for oldState, childScope in pairs(oldScopes) do
				doCleanup(childScope)
				scopePool.clearAndGive(childScope)
			end
		end
	
		table.insert(scope, function()
			value = nil
			updateChildren()
		end)
	
		-- perform initial child parenting
		updateChildren()
	end
} :: Types.SpecialKey ]]
_57f0a784b6878581c404cdc080a3057d.Children["_583ba759b934dc5c5b06b333e50a89ae"] = _583ba759b934dc5c5b06b333e50a89ae
local _583ba759b934dc5c5b06b333e50a89ae = nil -- DEALLOCATE PLS :pray:

local _72e7a57d66580ad6791af44c52c56e90 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_72e7a57d66580ad6791af44c52c56e90.Name = "Hydrate"
_72e7a57d66580ad6791af44c52c56e90.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Processes and returns an existing instance, with options for setting
	properties, event handlers and other attributes on the instance.
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local applyInstanceProps = require(Package.Instances.applyInstanceProps)
local logError = require(Package.Logging.logError)

local function Hydrate(
	scope: Types.Scope<unknown>,
	target: Instance
)
	if target :: any == nil then
		logError("scopeMissing", nil, "instances using Hydrate", "myScope:Hydrate (instance) { ... }")
	end
	return function(
		props: Types.PropertyTable
	): Instance
	
		table.insert(scope, target)
		applyInstanceProps(scope, props, target)
		return target
	end
end

return Hydrate ]]
_57f0a784b6878581c404cdc080a3057d.Children["_72e7a57d66580ad6791af44c52c56e90"] = _72e7a57d66580ad6791af44c52c56e90
local _72e7a57d66580ad6791af44c52c56e90 = nil -- DEALLOCATE PLS :pray:

local _f1f5dc75f8136b39324f9f80ea90c3f7 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_f1f5dc75f8136b39324f9f80ea90c3f7.Name = "New"
_f1f5dc75f8136b39324f9f80ea90c3f7.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Constructs and returns a new instance, with options for setting properties,
	event handlers and other attributes on the instance right away.
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local defaultProps = require(Package.Instances.defaultProps)
local applyInstanceProps = require(Package.Instances.applyInstanceProps)
local logError= require(Package.Logging.logError)

local function New(
	scope: Types.Scope<unknown>,
	className: string
)
	if (className :: any) == nil then
		local scope = (scope :: any) :: string
		logError("scopeMissing", nil, "instances using New", "myScope:New \"" .. scope .. "\" { ... }")
	end
	return function(
		props: Types.PropertyTable
	): Instance
		local ok, instance = pcall(Instance.new, className)
		if not ok then
			logError("cannotCreateClass", nil, className)
		end

		local classDefaults = defaultProps[className]
		if classDefaults ~= nil then
			for defaultProp, defaultValue in pairs(classDefaults) do
				(instance :: any)[defaultProp] = defaultValue
			end
		end

		table.insert(scope, instance)
		applyInstanceProps(scope, props, instance)

		return instance
	end
end

return New ]]
_57f0a784b6878581c404cdc080a3057d.Children["_f1f5dc75f8136b39324f9f80ea90c3f7"] = _f1f5dc75f8136b39324f9f80ea90c3f7
local _f1f5dc75f8136b39324f9f80ea90c3f7 = nil -- DEALLOCATE PLS :pray:

local _94cb8f47016adf2c5ca5a3c21474d098 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_94cb8f47016adf2c5ca5a3c21474d098.Name = "OnChange"
_94cb8f47016adf2c5ca5a3c21474d098.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Constructs special keys for property tables which connect property change
	listeners to an instance.
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local logError = require(Package.Logging.logError)

local keyCache: {[string]: Types.SpecialKey} = {}

local function OnChange(
	propertyName: string
): Types.SpecialKey
	local key = keyCache[propertyName]
	if key == nil then
		key = {
			type = "SpecialKey",
			kind = "OnChange",
			stage = "observer",
			apply = function(
				self: Types.SpecialKey,
				scope: Types.Scope<unknown>,
				callback: unknown,
				applyTo: Instance
			)
				local ok, event = pcall(applyTo.GetPropertyChangedSignal, applyTo, propertyName)
				if not ok then
					logError("cannotConnectChange", nil, applyTo.ClassName, propertyName)
				elseif typeof(callback) ~= "function" then
					logError("invalidChangeHandler", nil, propertyName)
				else
					local callback = callback :: (...unknown) -> (...unknown)
					table.insert(scope, event:Connect(function()
						callback((applyTo :: any)[propertyName])
					end))
				end
			end
		}
		keyCache[propertyName] = key
	end
	return key
end

return OnChange ]]
_57f0a784b6878581c404cdc080a3057d.Children["_94cb8f47016adf2c5ca5a3c21474d098"] = _94cb8f47016adf2c5ca5a3c21474d098
local _94cb8f47016adf2c5ca5a3c21474d098 = nil -- DEALLOCATE PLS :pray:

local _9994ef3a91309405a3a1040fde8d7566 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_9994ef3a91309405a3a1040fde8d7566.Name = "OnEvent"
_9994ef3a91309405a3a1040fde8d7566.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Constructs special keys for property tables which connect event listeners to
	an instance.
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local logError = require(Package.Logging.logError)

local keyCache: {[string]: Types.SpecialKey} = {}

local function getProperty_unsafe(
	instance: Instance,
	property: string
)
	return (instance :: any)[property]
end

local function OnEvent(
	eventName: string
): Types.SpecialKey
	local key = keyCache[eventName]
	if key == nil then
		key = {
			type = "SpecialKey",
			kind = "OnEvent",
			stage = "observer",
			apply = function(
				self: Types.SpecialKey,
				scope: Types.Scope<unknown>,
				callback: unknown,
				applyTo: Instance
			)
				local ok, event = pcall(getProperty_unsafe, applyTo, eventName)
				if not ok or typeof(event) ~= "RBXScriptSignal" then
					logError("cannotConnectEvent", nil, applyTo.ClassName, eventName)
				elseif typeof(callback) ~= "function" then
					logError("invalidEventHandler", nil, eventName)
				else
					table.insert(scope, event:Connect(callback :: any))
				end
			end
		}
		keyCache[eventName] = key
	end
	return key
end

return OnEvent ]]
_57f0a784b6878581c404cdc080a3057d.Children["_9994ef3a91309405a3a1040fde8d7566"] = _9994ef3a91309405a3a1040fde8d7566
local _9994ef3a91309405a3a1040fde8d7566 = nil -- DEALLOCATE PLS :pray:

local _ecdeb259262c8a8470c360c32b4c7002 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_ecdeb259262c8a8470c360c32b4c7002.Name = "Out"
_ecdeb259262c8a8470c360c32b4c7002.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	A special key for property tables, which allows users to extract values from
	an instance into an automatically-updated Value object.
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local logError = require(Package.Logging.logError)
local logWarn = require(Package.Logging.logWarn)
local isState = require(Package.State.isState)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)

local keyCache: {[string]: Types.SpecialKey} = {}

local function Out(
	propertyName: string
): Types.SpecialKey
	local key = keyCache[propertyName]
	if key == nil then
		key = {
			type = "SpecialKey",
			kind = "Out",
			stage = "observer",
			apply = function(
				self: Types.SpecialKey,
				scope: Types.Scope<unknown>,
				value: unknown,
				applyTo: Instance
			)
				local ok, event = pcall(applyTo.GetPropertyChangedSignal, applyTo, propertyName)
				if not ok then
					logError("invalidOutProperty", nil, applyTo.ClassName, propertyName)
				end
	
				if not isState(value) then
					logError("invalidOutType")
				end
				local value = value :: Types.StateObject<unknown>
				if value.kind ~= "Value" then
					logError("invalidOutType")
				end
				local value = value :: Types.Value<unknown>
	
				if value.scope == nil then
					logError("useAfterDestroy", nil, `The Value, which [Out "{propertyName}"] outputs to,`, `the {applyTo.ClassName} instance`)
				elseif whichLivesLonger(scope, applyTo, value.scope, value) == "definitely-a" then
					logWarn("possiblyOutlives", `The Value, which [Out "{propertyName}"] outputs to,`, `the {applyTo.ClassName} instance`)
				end
				value:set((applyTo :: any)[propertyName])
				table.insert(
					scope,
					event:Connect(function()
						value:set((applyTo :: any)[propertyName])
					end)
				)
			end
		}
		keyCache[propertyName] = key
	end
	return key
end

return Out ]]
_57f0a784b6878581c404cdc080a3057d.Children["_ecdeb259262c8a8470c360c32b4c7002"] = _ecdeb259262c8a8470c360c32b4c7002
local _ecdeb259262c8a8470c360c32b4c7002 = nil -- DEALLOCATE PLS :pray:

local _01b3be06db36c403ebc32fcb0ceab126 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_01b3be06db36c403ebc32fcb0ceab126.Name = "Ref"
_01b3be06db36c403ebc32fcb0ceab126.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	A special key for property tables, which stores a reference to the instance
	in a user-provided Value object.
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local logWarn = require(Package.Logging.logWarn)
local logError = require(Package.Logging.logError)
local isState = require(Package.State.isState)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)

return {
	type = "SpecialKey",
	kind = "Ref",
	stage = "observer",
	apply = function(
		self: Types.SpecialKey,
		scope: Types.Scope<unknown>,
		value: unknown,
		applyTo: Instance
	)
		if not isState(value) then
			logError("invalidRefType")
		end
		local value = value :: Types.StateObject<unknown>
		if value.kind ~= "Value" then
			logError("invalidRefType")
		end
		local value = value :: Types.Value<unknown>

		if value.scope == nil then
			logError("useAfterDestroy", nil, "The Value object, which [Ref] outputs to,", `the {applyTo} instance`)
		elseif whichLivesLonger(scope, applyTo, value.scope, value) == "definitely-a" then
			logWarn("possiblyOutlives", "The Value object, which [Ref] outputs to,", `the {applyTo} instance`)
		end
		value:set(applyTo)
	end
} :: Types.SpecialKey ]]
_57f0a784b6878581c404cdc080a3057d.Children["_01b3be06db36c403ebc32fcb0ceab126"] = _01b3be06db36c403ebc32fcb0ceab126
local _01b3be06db36c403ebc32fcb0ceab126 = nil -- DEALLOCATE PLS :pray:

local _00fb05e29568655c301f2b96e3392fc9 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_00fb05e29568655c301f2b96e3392fc9.Name = "applyInstanceProps"
_00fb05e29568655c301f2b96e3392fc9.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Applies a table of properties to an instance, including binding to any
	given state objects and applying any special keys.

	No strong reference is kept by default - special keys should take care not
	to accidentally hold strong references to instances forever.

	If a key is used twice, an error will be thrown. This is done to avoid
	double assignments or double bindings. However, some special keys may want
	to enable such assignments - in which case unique keys should be used for
	each occurence.
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local isState = require(Package.State.isState)
local logError = require(Package.Logging.logError)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local logWarn = require(Package.Logging.logWarn)
local parseError = require(Package.Logging.parseError)
local Observer = require(Package.State.Observer)
local peek = require(Package.State.peek)
local xtypeof = require(Package.Utility.xtypeof)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)

local function setProperty_unsafe(
	instance: Instance,
	property: string,
	value: unknown
)
	(instance :: any)[property] = value
end

local function testPropertyAssignable(
	instance: Instance,
	property: string
)
	(instance :: any)[property] = (instance :: any)[property]
end

local function setProperty(
	instance: Instance,
	property: string,
	value: unknown
)
	local success, err = xpcall(setProperty_unsafe :: any, parseError, instance, property, value)

	if not success then
		if not pcall(testPropertyAssignable, instance, property) then
			logErrorNonFatal("cannotAssignProperty", nil, instance.ClassName, property)
		else
			-- property is assignable, but this specific assignment failed
			-- this typically implies the wrong type was received
			local givenType = typeof(value)
			local expectedType = typeof((instance :: any)[property])

			if givenType == expectedType then
				logErrorNonFatal("propertySetError", err)
			else
				logErrorNonFatal("invalidPropertyType", nil, instance.ClassName, property, expectedType, givenType)
			end
		end
	end
end

local function bindProperty(
	scope: Types.Scope<unknown>,
	instance: Instance,
	property: string,
	value: Types.UsedAs<unknown>
)
	if isState(value) then
		local value = value :: Types.StateObject<unknown>
		if value.scope == nil then
			logError("useAfterDestroy", nil, `The {value.kind} object, bound to {property},`, `the {instance.ClassName} instance`)
		elseif whichLivesLonger(scope, instance, value.scope, value) == "definitely-a" then
			logWarn("possiblyOutlives", `The {value.kind} object, bound to {property},`, `the {instance.ClassName} instance`)
		end
		-- value is a state object - bind to changes
		Observer(scope, value :: any):onBind(function()
			setProperty(instance, property, peek(value))
		end)
	else
		-- value is a constant - assign once only
		setProperty(instance, property, value)
	end
end

local function applyInstanceProps(
	scope: Types.Scope<unknown>,
	props: Types.PropertyTable,
	applyTo: Instance
)
	local specialKeys = {
		self = {} :: {[Types.SpecialKey]: unknown},
		descendants = {} :: {[Types.SpecialKey]: unknown},
		ancestor = {} :: {[Types.SpecialKey]: unknown},
		observer = {} :: {[Types.SpecialKey]: unknown}
	}

	for key, value in pairs(props) do
		local keyType = xtypeof(key)

		if keyType == "string" then
			if key ~= "Parent" then
				bindProperty(scope, applyTo, key :: string, value)
			end
		elseif keyType == "SpecialKey" then
			local stage = (key :: Types.SpecialKey).stage
			local keys = specialKeys[stage]
			if keys == nil then
				logError("unrecognisedPropertyStage", nil, stage)
			else
				keys[key] = value
			end
		else
			-- we don't recognise what this key is supposed to be
			logError("unrecognisedPropertyKey", nil, keyType)
		end
	end

	for key, value in pairs(specialKeys.self) do
		key:apply(scope, value, applyTo)
	end
	for key, value in pairs(specialKeys.descendants) do
		key:apply(scope, value, applyTo)
	end

	if props.Parent ~= nil then
		bindProperty(scope, applyTo, "Parent", props.Parent)
	end

	for key, value in pairs(specialKeys.ancestor) do
		key:apply(scope, value, applyTo)
	end
	for key, value in pairs(specialKeys.observer) do
		key:apply(scope, value, applyTo)
	end
end

return applyInstanceProps ]]
_57f0a784b6878581c404cdc080a3057d.Children["_00fb05e29568655c301f2b96e3392fc9"] = _00fb05e29568655c301f2b96e3392fc9
local _00fb05e29568655c301f2b96e3392fc9 = nil -- DEALLOCATE PLS :pray:

local _96dbd5a16d483462fb404b19bc126fca = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_96dbd5a16d483462fb404b19bc126fca.Name = "defaultProps"
_96dbd5a16d483462fb404b19bc126fca.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Stores 'sensible default' properties to be applied to instances created by
	the New function.
\]\]

return {
	ScreenGui = {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	},

	BillboardGui = {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Active = true
	},

	SurfaceGui = {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

		SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
		PixelsPerStud = 50
	},

	Frame = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0
	},

	ScrollingFrame = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,

		ScrollBarImageColor3 = Color3.new(0, 0, 0)
	},

	TextLabel = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,

		Font = Enum.Font.SourceSans,
		Text = "",
		TextColor3 = Color3.new(0, 0, 0),
		TextSize = 14
	},

	TextButton = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,

		AutoButtonColor = false,

		Font = Enum.Font.SourceSans,
		Text = "",
		TextColor3 = Color3.new(0, 0, 0),
		TextSize = 14
	},

	TextBox = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,

		ClearTextOnFocus = false,

		Font = Enum.Font.SourceSans,
		Text = "",
		TextColor3 = Color3.new(0, 0, 0),
		TextSize = 14
	},

	ImageLabel = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0
	},

	ImageButton = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,

		AutoButtonColor = false
	},

	ViewportFrame = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0
	},

	VideoFrame = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0
	},
	
	CanvasGroup = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0
	},

	SpawnLocation = {
		Duration = 0
	},

	BoxHandleAdornment = {
		ZIndex = 0
	},
	ConeHandleAdornment = {
		ZIndex = 0
	},
	CylinderHandleAdornment = {
		ZIndex = 0
	},
	ImageHandleAdornment = {
		ZIndex = 0
	},
	LineHandleAdornment = {
		ZIndex = 0
	},
	SphereHandleAdornment = {
		ZIndex = 0
	},
	WireframeHandleAdornment = {
		ZIndex = 0
	},
	
	Part = {
		Anchored = true,
		Size = Vector3.one,
		FrontSurface = Enum.SurfaceType.Smooth,
		BackSurface = Enum.SurfaceType.Smooth,
		LeftSurface = Enum.SurfaceType.Smooth,
		RightSurface = Enum.SurfaceType.Smooth,
		TopSurface = Enum.SurfaceType.Smooth,
		BottomSurface = Enum.SurfaceType.Smooth,
	},
	
	TrussPart = {
		Anchored = true,
		Size = Vector3.one * 2,
		FrontSurface = Enum.SurfaceType.Smooth,
		BackSurface = Enum.SurfaceType.Smooth,
		LeftSurface = Enum.SurfaceType.Smooth,
		RightSurface = Enum.SurfaceType.Smooth,
		TopSurface = Enum.SurfaceType.Smooth,
		BottomSurface = Enum.SurfaceType.Smooth,
	},

	MeshPart = {
		Anchored = true,
		Size = Vector3.one,
		FrontSurface = Enum.SurfaceType.Smooth,
		BackSurface = Enum.SurfaceType.Smooth,
		LeftSurface = Enum.SurfaceType.Smooth,
		RightSurface = Enum.SurfaceType.Smooth,
		TopSurface = Enum.SurfaceType.Smooth,
		BottomSurface = Enum.SurfaceType.Smooth,
	},

	CornerWedgePart = {
		Anchored = true,
		Size = Vector3.one,
		FrontSurface = Enum.SurfaceType.Smooth,
		BackSurface = Enum.SurfaceType.Smooth,
		LeftSurface = Enum.SurfaceType.Smooth,
		RightSurface = Enum.SurfaceType.Smooth,
		TopSurface = Enum.SurfaceType.Smooth,
		BottomSurface = Enum.SurfaceType.Smooth,
	},

	VehicleSeat = {
		Anchored = true,
		Size = Vector3.one,
		FrontSurface = Enum.SurfaceType.Smooth,
		BackSurface = Enum.SurfaceType.Smooth,
		LeftSurface = Enum.SurfaceType.Smooth,
		RightSurface = Enum.SurfaceType.Smooth,
		TopSurface = Enum.SurfaceType.Smooth,
		BottomSurface = Enum.SurfaceType.Smooth,
	},
} ]]
_57f0a784b6878581c404cdc080a3057d.Children["_96dbd5a16d483462fb404b19bc126fca"] = _96dbd5a16d483462fb404b19bc126fca
local _96dbd5a16d483462fb404b19bc126fca = nil -- DEALLOCATE PLS :pray:

local _201ef66e146c33801769dd5114c5cf09 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_201ef66e146c33801769dd5114c5cf09.Name = "InternalTypes"
_201ef66e146c33801769dd5114c5cf09.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Stores common type information used internally.

	These types may be used internally so Fusion code can type-check, but
	should never be exposed to public users, as these definitions are fair game
	for breaking changes.
\]\]

local Package = script.Parent
local Types = require(Package.Types)

--\[\[
	General use types
\]\]

-- Stores useful information about Luau errors.
export type Error = {
	type: string, -- replace with "Error" when Luau supports singleton types
	raw: string,
	message: string,
	trace: string
}

-- An object which stores a value scoped in time.
export type Contextual<T> = Types.Contextual<T> & {
	_valuesNow: {[thread]: {value: T}},
	_defaultValue: T
}

--\[\[
	Generic reactive graph types
\]\]

export type StateObject<T> = Types.StateObject<T> & {
	_peek: (StateObject<T>) -> T
}

--\[\[
	Specific reactive graph types
\]\]

-- A state object whose value can be set at any time by the user.
export type Value<T, S = T> = Types.Value<T, S> & {
	_value: S
}

-- A state object whose value is derived from other objects using a callback.
export type Computed<T, S> = Types.Computed<T> & {
	scope: Types.Scope<S>?,
	_oldDependencySet: {[Types.Dependency]: unknown},
	_processor: (Types.Use, Types.Scope<S>) -> T,
	_value: T,
	_innerScope: Types.Scope<S>?
}

-- A state object which maps over keys and/or values in another table.
export type For<KI, KO, VI, VO, S> = Types.For<KO, VO> & {
	scope: Types.Scope<S>?,
	_processor: (
		Types.Scope<S>,
		Types.StateObject<{key: KI, value: VI}>
	) -> (Types.StateObject<{key: KO?, value: VO?}>),
	_inputTable: Types.UsedAs<{[KI]: VI}>,
	_existingInputTable: {[KI]: VI}?,
	_existingOutputTable: {[KO]: VO},
	_existingProcessors: {[ForProcessor]: true},
	_newOutputTable: {[KO]: VO},
	_newProcessors: {[ForProcessor]: true},
	_remainingPairs: {[KI]: {[VI]: true}}
}
type ForProcessor = {
	inputPair: Types.Value<{key: unknown, value: unknown}>,
	outputPair: Types.StateObject<{key: unknown, value: unknown}>,
	scope: Types.Scope<unknown>?
}

-- A state object which follows another state object using tweens.
export type Tween<T> = Types.Tween<T> & {
	_goal: Types.UsedAs<T>,
	_tweenInfo: TweenInfo,
	_prevValue: T,
	_nextValue: T,
	_currentValue: T,
	_currentTweenInfo: TweenInfo,
	_currentTweenDuration: number,
	_currentTweenStartTime: number,
	_currentlyAnimating: boolean
}

-- A state object which follows another state object using spring simulation.
export type Spring<T> = Types.Spring<T> & {
	_speed: Types.UsedAs<number>,
	_damping: Types.UsedAs<number>,
	_goal: Types.UsedAs<T>,
	_goalValue: T,

	_currentType: string,
	_currentValue: T,
	_currentSpeed: number,
	_currentDamping: number,

	_springPositions: {number},
	_springGoals: {number},
	_springVelocities: {number},

	_lastSchedule: number,
	_startDisplacements: {number},
	_startVelocities: {number}
}

-- An object which can listen for updates on another state object.
export type Observer = Types.Observer & {
	_changeListeners: {[{}]: () -> ()},
	_numChangeListeners: number
}

return nil ]]
_d56864cbc3c61714243504ffab872304.Children["_201ef66e146c33801769dd5114c5cf09"] = _201ef66e146c33801769dd5114c5cf09
local _201ef66e146c33801769dd5114c5cf09 = nil -- DEALLOCATE PLS :pray:

local _60957cac1c271eef57101fe1f975177b = { ClassName = "Folder", Children = {}, Properties = {} }
_60957cac1c271eef57101fe1f975177b.Name = "Logging"
_d56864cbc3c61714243504ffab872304.Children["_60957cac1c271eef57101fe1f975177b"] = _60957cac1c271eef57101fe1f975177b
local _60957cac1c271eef57101fe1f975177b = nil -- DEALLOCATE PLS :pray:
local _07bf2f029ea27b0f423e291b56e73a34 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_07bf2f029ea27b0f423e291b56e73a34.Name = "logError"
_07bf2f029ea27b0f423e291b56e73a34.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Utility function to log a Fusion-specific error.
\]\]

local Package = script.Parent.Parent
local InternalTypes = require(Package.InternalTypes)
local messages = require(Package.Logging.messages)

local function logError(
	messageID: string,
	errObj: InternalTypes.Error?,
	...: unknown
)
	local formatString: string

	if messages[messageID] ~= nil then
		formatString = messages[messageID]
	else
		messageID = "unknownMessage"
		formatString = messages[messageID]
	end

	local errorString
	if errObj == nil then
		errorString = string.format("[Fusion] " .. formatString .. "\n(ID: " .. messageID .. ")", ...)
	else
		formatString = formatString:gsub("ERROR_MESSAGE", errObj.message)
		errorString = string.format("[Fusion] " .. formatString .. "\n(ID: " .. messageID .. ")\n---- Stack trace ----\n" .. errObj.trace, ...)
	end

	error(errorString:gsub("\n", "\n    "), 0)
end

return logError ]]
_60957cac1c271eef57101fe1f975177b.Children["_07bf2f029ea27b0f423e291b56e73a34"] = _07bf2f029ea27b0f423e291b56e73a34
local _07bf2f029ea27b0f423e291b56e73a34 = nil -- DEALLOCATE PLS :pray:

local _32cdc6d51fb65839b18c34be4ac74267 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_32cdc6d51fb65839b18c34be4ac74267.Name = "logErrorNonFatal"
_32cdc6d51fb65839b18c34be4ac74267.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
-- local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Utility function to log a Fusion-specific error, without halting execution.
\]\]

local Package = script.Parent.Parent
local InternalTypes = require(Package.InternalTypes)
local External = require(Package.External)
local messages = require(Package.Logging.messages)

local function logErrorNonFatal(
	messageID: string,
	errObj: InternalTypes.Error?,
	...: unknown
)	
	local formatString: string

	if messages[messageID] ~= nil then
		formatString = messages[messageID]
	else
		messageID = "unknownMessage"
		formatString = messages[messageID]
	end

	local errorString
	if errObj == nil then
		errorString = string.format("[Fusion] " .. formatString .. "\n(ID: " .. messageID .. ")", ...)
	else
		formatString = formatString:gsub("ERROR_MESSAGE", errObj.message)
		errorString = string.format("[Fusion] " .. formatString .. "\n(ID: " .. messageID .. ")\n---- Stack trace ----\n" .. errObj.trace, ...)
	end

	local errorString = errorString:gsub("\n", "\n    ")
	External.errorNonFatal(errorString)
end

return logErrorNonFatal ]]
_60957cac1c271eef57101fe1f975177b.Children["_32cdc6d51fb65839b18c34be4ac74267"] = _32cdc6d51fb65839b18c34be4ac74267
local _32cdc6d51fb65839b18c34be4ac74267 = nil -- DEALLOCATE PLS :pray:

local _babf4bffc50fee8ef9c27294eb5d21cb = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_babf4bffc50fee8ef9c27294eb5d21cb.Name = "logWarn"
_babf4bffc50fee8ef9c27294eb5d21cb.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Utility function to log a Fusion-specific warning.
\]\]

local Package = script.Parent.Parent
local messages = require(Package.Logging.messages)

local function logWarn(
	messageID: string,
	...: unknown
)
	local formatString: string

	if messages[messageID] ~= nil then
		formatString = messages[messageID]
	else
		messageID = "unknownMessage"
		formatString = messages[messageID]
	end

	local warnMessage = string.format("[Fusion] " .. formatString .. "\n(ID: " .. messageID .. ")", ...)
	warnMessage ..=  "\n---- Stack trace ----\n" .. debug.traceback(nil, 3)
	warn(warnMessage)
end

return logWarn ]]
_60957cac1c271eef57101fe1f975177b.Children["_babf4bffc50fee8ef9c27294eb5d21cb"] = _babf4bffc50fee8ef9c27294eb5d21cb
local _babf4bffc50fee8ef9c27294eb5d21cb = nil -- DEALLOCATE PLS :pray:

local _6b33d4947b8415701604a3d2e71281a1 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_6b33d4947b8415701604a3d2e71281a1.Name = "messages"
_6b33d4947b8415701604a3d2e71281a1.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Stores templates for different kinds of logging messages.
\]\]

return {
	callbackError = "Error in callback: ERROR_MESSAGE",
	cannotAssignProperty = "The class type '%s' has no assignable property '%s'.",
	cannotConnectChange = "The %s class doesn't have a property called '%s'.",
	cannotConnectEvent = "The %s class doesn't have an event called '%s'.",
	cannotCreateClass = "Can't create a new instance of class '%s'.",
	cleanupWasRenamed = "`Fusion.cleanup` was renamed to `Fusion.doCleanup`. This will be an error in future versions of Fusion.",
	destroyedTwice = "Attempted to destroy %s twice; ensure you're not manually calling `:destroy()` while using scopes. See discussion #292 on GitHub for advice.",
	destructorRedundant = "%s destructors no longer do anything. If you wish to run code on destroy, `table.insert` a function into the `scope` argument. See discussion #292 on GitHub for advice.",
	forKeyCollision = "The key '%s' was returned multiple times simultaneously, which is not allowed in `For` objects.",
	invalidAttributeChangeHandler = "The change handler for the '%s' attribute must be a function.",
	invalidAttributeOutType = "[AttributeOut] properties must be given Value objects.",
	invalidChangeHandler = "The change handler for the '%s' property must be a function.",
	invalidEventHandler = "The handler for the '%s' event must be a function.",
	invalidOutProperty = "The %s class doesn't have a property called '%s'.",
	invalidOutType = "[Out] properties must be given Value objects.",
	invalidPropertyType = "'%s.%s' expected a '%s' type, but got a '%s' type.",
	invalidRefType = "Instance refs must be Value objects.",
	invalidSpringDamping = "The damping ratio for a spring must be >= 0. (damping was %.2f)",
	invalidSpringSpeed = "The speed of a spring must be >= 0. (speed was %.2f)",
	mergeConflict = "Multiple definitions for '%s' found while merging.",
	mistypedSpringDamping = "The damping ratio for a spring must be a number. (got a %s)",
	mistypedSpringSpeed = "The speed of a spring must be a number. (got a %s)",
	mistypedTweenInfo = "The tween info of a tween must be a TweenInfo. (got a %s)",
	noTaskScheduler = "Fusion is not connected to an external task scheduler.",
	possiblyOutlives = "%s could be destroyed before %s; review the order they're created in, and what scopes they belong to. See discussion #292 on GitHub for advice.",
	propertySetError = "Error setting property: ERROR_MESSAGE",
	scopeMissing = "To create %s, provide a scope. (e.g. `%s`). See discussion #292 on GitHub for advice.",
	springNanGoal = "A spring was given a NaN goal, so some simulation has been skipped. Ensure no springs have NaN goals.",
	springNanMotion = "A spring encountered NaN during motion, so has snapped to the goal position. Ensure no springs have NaN positions or velocities.",
	springTypeMismatch = "The type '%s' doesn't match the spring's type '%s'.",
	stateGetWasRemoved = "`StateObject:get()` has been replaced by `use()` and `peek()` - see discussion #217 on GitHub.",
	unknownMessage = "Unknown error: ERROR_MESSAGE",
	unrecognisedChildType = "'%s' type children aren't accepted by `[Children]`.",
	unrecognisedPropertyKey = "'%s' keys aren't accepted in property tables.",
	unrecognisedPropertyStage = "'%s' isn't a valid stage for a special key to be applied at.",
	useAfterDestroy = "%s is no longer valid - it was destroyed before %s. See discussion #292 on GitHub for advice."
} ]]
_60957cac1c271eef57101fe1f975177b.Children["_6b33d4947b8415701604a3d2e71281a1"] = _6b33d4947b8415701604a3d2e71281a1
local _6b33d4947b8415701604a3d2e71281a1 = nil -- DEALLOCATE PLS :pray:

local _bd14eef10d44ebddede8cd6aaec2ee17 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_bd14eef10d44ebddede8cd6aaec2ee17.Name = "parseError"
_bd14eef10d44ebddede8cd6aaec2ee17.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	An xpcall() error handler to collect and parse useful information about
	errors, such as clean messages and stack traces.
\]\]

local Package = script.Parent.Parent
local InternalTypes = require(Package.InternalTypes)

local function parseError(
	err: string
): InternalTypes.Error
	return {
		type = "Error",
		raw = err,
		message = err:gsub("^.+:%d+:%s*", ""),
		trace = debug.traceback(nil, 2)
	}
end

return parseError ]]
_60957cac1c271eef57101fe1f975177b.Children["_bd14eef10d44ebddede8cd6aaec2ee17"] = _bd14eef10d44ebddede8cd6aaec2ee17
local _bd14eef10d44ebddede8cd6aaec2ee17 = nil -- DEALLOCATE PLS :pray:

local _3439a48d55cc34457e0a8458f3490296 = { ClassName = "Folder", Children = {}, Properties = {} }
_3439a48d55cc34457e0a8458f3490296.Name = "Memory"
_d56864cbc3c61714243504ffab872304.Children["_3439a48d55cc34457e0a8458f3490296"] = _3439a48d55cc34457e0a8458f3490296
local _3439a48d55cc34457e0a8458f3490296 = nil -- DEALLOCATE PLS :pray:
local _c18e627dfc4750fb8a04bc76982e9ce9 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_c18e627dfc4750fb8a04bc76982e9ce9.Name = "deriveScope"
_c18e627dfc4750fb8a04bc76982e9ce9.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Creates an empty scope with the same metatables as the original scope. Used
	for preserving access to constructors when creating inner scopes.
\]\]
local Package = script.Parent.Parent
local Types = require(Package.Types)
local merge = require(Package.Utility.merge)
local scopePool = require(Package.Memory.scopePool)

-- This return type is technically a lie, but it's required for useful type
-- checking behaviour.
local function deriveScope<T>(
	existing: Types.Scope<T>,
	methods: {[unknown]: unknown}?,
	...: {[unknown]: unknown}
): any
	local metatable = getmetatable(existing)
	if methods ~= nil then
		metatable = table.clone(metatable)
		metatable.__index = merge("first", table.clone(metatable.__index), methods, ...)
	end
	return setmetatable(
		scopePool.reuseAny() :: any or {},
		metatable
	)
end

return (deriveScope :: any) :: Types.DeriveScopeConstructor ]]
_3439a48d55cc34457e0a8458f3490296.Children["_c18e627dfc4750fb8a04bc76982e9ce9"] = _c18e627dfc4750fb8a04bc76982e9ce9
local _c18e627dfc4750fb8a04bc76982e9ce9 = nil -- DEALLOCATE PLS :pray:

local _ab3b28446b500a6eb9b92eaf3c17b09b = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_ab3b28446b500a6eb9b92eaf3c17b09b.Name = "doCleanup"
_ab3b28446b500a6eb9b92eaf3c17b09b.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Cleans up the tasks passed in as the arguments.
	A task can be any of the following:

	- an Instance - will be destroyed
	- an RBXScriptConnection - will be disconnected
	- a function - will be run
	- a table with a `Destroy` or `destroy` function - will be called
	- an array - `cleanup` will be called on each item
\]\]

local function doCleanupOne(
	task: unknown
)
	local taskType = typeof(task)

	-- case 1: Instance
	if taskType == "Instance" then
		local task = task :: Instance
		task:Destroy()

	-- case 2: RBXScriptConnection
	elseif taskType == "RBXScriptConnection" then
		local task = task :: RBXScriptConnection
		task:Disconnect()

	-- case 3: callback
	elseif taskType == "function" then
		local task = task :: (...unknown) -> (...unknown)
		task()

	elseif taskType == "table" then
		local task = task :: {destroy: unknown?, Destroy: unknown?}

		-- case 4: destroy() function
		if typeof(task.destroy) == "function" then
			local task = (task :: any) :: {destroy: (...unknown) -> (...unknown)}
			task:destroy()

		-- case 5: Destroy() function
		elseif typeof(task.Destroy) == "function" then
			local task = (task :: any) :: {Destroy: (...unknown) -> (...unknown)}
			task:Destroy()

		-- case 6: array of tasks
		elseif task[1] ~= nil then
			local task = task :: {unknown}
			-- It is important to iterate backwards through the table, since
			-- objects are added in order of construction.
			for index = #task, 1, -1 do
				doCleanupOne(task[index])
				task[index] = nil
			end
		end
	end
end

local function doCleanup(
	...: unknown
)
	for index = 1, select("#", ...) do
		doCleanupOne(select(index, ...))
	end
end

return doCleanup ]]
_3439a48d55cc34457e0a8458f3490296.Children["_ab3b28446b500a6eb9b92eaf3c17b09b"] = _ab3b28446b500a6eb9b92eaf3c17b09b
local _ab3b28446b500a6eb9b92eaf3c17b09b = nil -- DEALLOCATE PLS :pray:

local _50a981df80613741b6cb06b5a1d7f582 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_50a981df80613741b6cb06b5a1d7f582.Name = "innerScope"
_50a981df80613741b6cb06b5a1d7f582.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Derives a new scope that's destroyed exactly once, whether by the user or by
	the scope that it's inside of.
\]\]
local Package = script.Parent.Parent
local Types = require(Package.Types)
local deriveScope = require(Package.Memory.deriveScope)

local function innerScope<T>(
	existing: Types.Scope<T>,
	...: {[unknown]: unknown}
): any
	local new = deriveScope(existing, ...)
	table.insert(existing, new)
	table.insert(
		new, 
		function()
			local index = table.find(existing, new)
			if index ~= nil then
				table.remove(existing, index)
			end
		end
	)
	return new
end

return (innerScope :: any) :: Types.DeriveScopeConstructor ]]
_3439a48d55cc34457e0a8458f3490296.Children["_50a981df80613741b6cb06b5a1d7f582"] = _50a981df80613741b6cb06b5a1d7f582
local _50a981df80613741b6cb06b5a1d7f582 = nil -- DEALLOCATE PLS :pray:

local _58d2ec7e7f7d76a723712fc9a7152d0f = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_58d2ec7e7f7d76a723712fc9a7152d0f.Name = "legacyCleanup"
_58d2ec7e7f7d76a723712fc9a7152d0f.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

local Package = script.Parent.Parent
local logWarn = require(Package.Logging.logWarn)
local doCleanup = require(Package.Memory.doCleanup)

local function legacyCleanup(
	...: unknown
)
	logWarn("cleanupWasRenamed")
	return doCleanup(...)
end

return legacyCleanup ]]
_3439a48d55cc34457e0a8458f3490296.Children["_58d2ec7e7f7d76a723712fc9a7152d0f"] = _58d2ec7e7f7d76a723712fc9a7152d0f
local _58d2ec7e7f7d76a723712fc9a7152d0f = nil -- DEALLOCATE PLS :pray:

local _7f47547275d0bd5c379d9316ec5567d8 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_7f47547275d0bd5c379d9316ec5567d8.Name = "needsDestruction"
_7f47547275d0bd5c379d9316ec5567d8.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Returns true if the given value is not automatically memory managed, and
	requires manual cleanup.
\]\]

local function needsDestruction(
	x: unknown
): boolean
	return typeof(x) == "Instance"
end

return needsDestruction ]]
_3439a48d55cc34457e0a8458f3490296.Children["_7f47547275d0bd5c379d9316ec5567d8"] = _7f47547275d0bd5c379d9316ec5567d8
local _7f47547275d0bd5c379d9316ec5567d8 = nil -- DEALLOCATE PLS :pray:

local _9c039cb6c9a44c94fb5f1b752a9d275b = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_9c039cb6c9a44c94fb5f1b752a9d275b.Name = "scopePool"
_9c039cb6c9a44c94fb5f1b752a9d275b.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

local Package = script.Parent.Parent
local Types = require(Package.Types)

local MAX_POOL_SIZE = 16 -- TODO: need to test what an ideal number for this is

local pool = {}
local poolSize = 0

return {
	giveIfEmpty = function<S>(
		scope: Types.Scope<S>
	): Types.Scope<S>?
		if next(scope) == nil then
			if poolSize < MAX_POOL_SIZE then
				poolSize += 1
				pool[poolSize] = scope
			end
			return nil
		else
			return scope
		end
	end,
	clearAndGive = function(
		scope: Types.Scope<unknown>
	)
		if poolSize < MAX_POOL_SIZE then
			table.clear(scope)
			poolSize += 1
			pool[poolSize] = scope :: any
		end
	end,
	reuseAny = function(): Types.Scope<unknown>
		if poolSize == 0 then
			return nil :: any
		else
			local scope = pool[poolSize]
			poolSize -= 1
			return scope
		end
	end
} ]]
_3439a48d55cc34457e0a8458f3490296.Children["_9c039cb6c9a44c94fb5f1b752a9d275b"] = _9c039cb6c9a44c94fb5f1b752a9d275b
local _9c039cb6c9a44c94fb5f1b752a9d275b = nil -- DEALLOCATE PLS :pray:

local _a6caaa346f4173113b81b2209da47989 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_a6caaa346f4173113b81b2209da47989.Name = "scoped"
_a6caaa346f4173113b81b2209da47989.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Creates cleanup tables with access to constructors as methods.
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local merge = require(Package.Utility.merge)
local scopePool = require(Package.Memory.scopePool)

local function scoped(
	...: {[unknown]: unknown}
): any
	return setmetatable(
		scopePool.reuseAny() :: any or {},
		{__index = merge("none", {}, ...)}
	)
end

return (scoped :: any) :: Types.ScopedConstructor ]]
_3439a48d55cc34457e0a8458f3490296.Children["_a6caaa346f4173113b81b2209da47989"] = _a6caaa346f4173113b81b2209da47989
local _a6caaa346f4173113b81b2209da47989 = nil -- DEALLOCATE PLS :pray:

local _ae7fefbc859d43e2bcd3aab3fb58fb3b = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_ae7fefbc859d43e2bcd3aab3fb58fb3b.Name = "whichLivesLonger"
_ae7fefbc859d43e2bcd3aab3fb58fb3b.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Calculates how the lifetimes of the two values relate. Specifically, it
	calculates which value will be destroyed earlier or later, if it is possible
	to infer this from their scopes.
\]\]
local Package = script.Parent.Parent
local Types = require(Package.Types)

local function whichScopeLivesLonger(
	scopeA: Types.Scope<unknown>,
	scopeB: Types.Scope<unknown>
): "definitely-a" | "definitely-b" | "unsure"
	-- If we can prove one scope is inside of the other scope, then the outer
	-- scope must live longer than the inner scope (assuming idiomatic scopes).
	-- So, we will search the scopes recursively until we find one of them, at
	-- which point we know they must have been found inside the other scope.
	local openSet, nextOpenSet = {scopeA, scopeB}, {}
	local openSetSize, nextOpenSetSize = 2, 0
	local closedSet = {}
	while openSetSize > 0 do
		for _, scope in openSet do
			closedSet[scope] = true
			for _, inScope in ipairs(scope) do
				if inScope == scopeA then
					return "definitely-b"
				elseif inScope == scopeB then
					return "definitely-a"
				elseif typeof(inScope) == "table" then
					local inScope = inScope :: {unknown}
					if inScope[1] ~= nil and closedSet[scope] == nil then
						nextOpenSetSize += 1
						nextOpenSet[nextOpenSetSize] = inScope
					end
				end 
			end
		end
		table.clear(openSet)
		openSet, nextOpenSet = nextOpenSet, openSet
		openSetSize, nextOpenSetSize = nextOpenSetSize, 0
	end
	return "unsure"
end

local function whichLivesLonger(
	scopeA: Types.Scope<unknown>,
	a: unknown,
	scopeB: Types.Scope<unknown>,
	b: unknown
): "definitely-a" | "definitely-b" | "unsure"
	if scopeA == scopeB then
		local scopeA: {unknown} = scopeA
		for index = #scopeA, 1, -1 do
			local value = scopeA[index]
			if value == a then
				return "definitely-b"
			elseif value == b then
				return "definitely-a"
			end
		end
		return "unsure"
	else
		return whichScopeLivesLonger(scopeA, scopeB)
	end
end

return whichLivesLonger ]]
_3439a48d55cc34457e0a8458f3490296.Children["_ae7fefbc859d43e2bcd3aab3fb58fb3b"] = _ae7fefbc859d43e2bcd3aab3fb58fb3b
local _ae7fefbc859d43e2bcd3aab3fb58fb3b = nil -- DEALLOCATE PLS :pray:

local _09def814eeb77cdcf1dc2c780c74f491 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_09def814eeb77cdcf1dc2c780c74f491.Name = "RobloxExternal"
_09def814eeb77cdcf1dc2c780c74f491.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow

--\[\[
	Roblox implementation for Fusion's abstract scheduler layer.
\]\]

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Package = script.Parent
local External = require(Package.External)

local RobloxExternal = {}

--\[\[
   Sends an immediate task to the external scheduler. Throws if none is set.
\]\]
function RobloxExternal.doTaskImmediate(
	resume: () -> ()
)
   task.spawn(resume)
end

--\[\[
	Sends a deferred task to the external scheduler. Throws if none is set.
\]\]
function RobloxExternal.doTaskDeferred(
	resume: () -> ()
)
	task.defer(resume)
end

--\[\[
	Errors in a different thread to preserve the flow of execution.
\]\]
function RobloxExternal.errorNonFatal(
	err: unknown
)
	task.spawn(error, err, 0)
end

--\[\[
	Sends an update step to Fusion using the Roblox clock time.
\]\]
local function performUpdateStep()
	External.performUpdateStep(os.clock())
end

--\[\[
	Binds Fusion's update step to RunService step events.
\]\]
local stopSchedulerFunc = nil :: (() -> ())?
function RobloxExternal.startScheduler()
	if stopSchedulerFunc ~= nil then
		return
	end
	if RunService:IsClient() then
		-- In cases where multiple Fusion modules are running simultaneously,
		-- this prevents collisions.
		local id = "FusionUpdateStep_" .. HttpService:GenerateGUID()
		RunService:BindToRenderStep(
			id,
			Enum.RenderPriority.First.Value,
			performUpdateStep
		)
		stopSchedulerFunc = function()
			RunService:UnbindFromRenderStep(id)
		end
	else
		local connection = RunService.Heartbeat:Connect(performUpdateStep)
		stopSchedulerFunc = function()
			connection:Disconnect()
		end
	end
end

--\[\[
	Unbinds Fusion's update step from RunService step events.
\]\]
function RobloxExternal.stopScheduler()
	if stopSchedulerFunc ~= nil then
		stopSchedulerFunc()
		stopSchedulerFunc = nil
	end
end

return RobloxExternal ]]
_d56864cbc3c61714243504ffab872304.Children["_09def814eeb77cdcf1dc2c780c74f491"] = _09def814eeb77cdcf1dc2c780c74f491
local _09def814eeb77cdcf1dc2c780c74f491 = nil -- DEALLOCATE PLS :pray:

local _3a83d9b6e14f598dcdf75ad65acdfecb = { ClassName = "Folder", Children = {}, Properties = {} }
_3a83d9b6e14f598dcdf75ad65acdfecb.Name = "State"
_d56864cbc3c61714243504ffab872304.Children["_3a83d9b6e14f598dcdf75ad65acdfecb"] = _3a83d9b6e14f598dcdf75ad65acdfecb
local _3a83d9b6e14f598dcdf75ad65acdfecb = nil -- DEALLOCATE PLS :pray:
local _57344aa22dd82be83d72380d960ccff0 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_57344aa22dd82be83d72380d960ccff0.Name = "Computed"
_57344aa22dd82be83d72380d960ccff0.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Constructs and returns objects which can be used to model derived reactive
	state.
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local InternalTypes = require(Package.InternalTypes)
-- Logging
local logError = require(Package.Logging.logError)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local logWarn = require(Package.Logging.logWarn)
local parseError = require(Package.Logging.parseError)
-- Utility
local isSimilar = require(Package.Utility.isSimilar)
-- State
local isState = require(Package.State.isState)
-- Memory
local doCleanup = require(Package.Memory.doCleanup)
local deriveScope = require(Package.Memory.deriveScope)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)
local scopePool = require(Package.Memory.scopePool)

local class = {}
class.type = "State"
class.kind = "Computed"

local CLASS_METATABLE = {__index = class}

--\[\[
	Called when a dependency changes value.
	Recalculates this Computed's cached value and dependencies.
	Returns true if it changed, or false if it's identical.
\]\]
function class:update(): boolean
	local self = self :: InternalTypes.Computed<unknown, unknown>
	if self.scope == nil then
		return false
	end
	local outerScope = self.scope :: Types.Scope<unknown>

	-- remove this object from its dependencies' dependent sets
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end

	-- we need to create a new, empty dependency set to capture dependencies
	-- into, but in case there's an error, we want to restore our old set of
	-- dependencies. by using this table-swapping solution, we can avoid the
	-- overhead of allocating new tables each update.
	self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet
	table.clear(self.dependencySet)

	local innerScope = deriveScope(outerScope)
	local function use<T>(target: Types.UsedAs<T>): T
		if isState(target) then
			local target = target :: Types.StateObject<T>
			if target.scope == nil then
				logError("useAfterDestroy", nil, `The {target.kind} object`, "the Computed that is use()-ing it")
			elseif whichLivesLonger(outerScope, self, target.scope, target) == "definitely-a" then
				logWarn("possiblyOutlives", `The {target.kind} object`, "the Computed that is use()-ing it")
			end		
			self.dependencySet[target] = true
			return (target :: InternalTypes.StateObject<T>):_peek()
		else
			return target :: T
		end
	end
	local ok, newValue = xpcall(self._processor, parseError, use, innerScope)
	local innerScope = scopePool.giveIfEmpty(innerScope)

	if ok then
		local oldValue = self._value
		local similar = isSimilar(oldValue, newValue)
		if self._innerScope ~= nil then
			doCleanup(self._innerScope)
			scopePool.clearAndGive(self._innerScope)
		end
		self._value = newValue
		self._innerScope = innerScope

		-- add this object to the dependencies' dependent sets
		for dependency in pairs(self.dependencySet) do
			dependency.dependentSet[self] = true
		end

		return not similar
	else
		local errorObj = (newValue :: any) :: InternalTypes.Error
		-- this needs to be non-fatal, because otherwise it'd disrupt the
		-- update process
		logErrorNonFatal("callbackError", errorObj)

		if innerScope ~= nil then
			doCleanup(innerScope)
			scopePool.clearAndGive(self._innerScope :: any)
			self._innerScope = nil
		end

		-- restore old dependencies, because the new dependencies may be corrupt
		self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet

		-- restore this object in the dependencies' dependent sets
		for dependency in pairs(self.dependencySet) do
			dependency.dependentSet[self] = true
		end

		return false
	end
end

--\[\[
	Returns the interior value of this state object.
\]\]
function class:_peek(): unknown
	local self = self :: InternalTypes.Computed<unknown, unknown>
	return self._value
end

function class:get()
	logError("stateGetWasRemoved")
end

function class:destroy()
	local self = self :: InternalTypes.Computed<unknown, unknown>
	if self.scope == nil then
		logError("destroyedTwice", nil, "Computed")
	end
	self.scope = nil
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end
	if self._innerScope ~= nil then
		doCleanup(self._innerScope)
		scopePool.clearAndGive(self._innerScope)
	end
end

local function Computed<T, S>(
	scope: Types.Scope<S>,
	processor: (Types.Use, Types.Scope<S>) -> T,
	destructor: unknown?
): Types.Computed<T>
	if typeof(scope) == "function" then
		logError("scopeMissing", nil, "Computeds", "myScope:Computed(function(use, scope) ... end)")
	elseif destructor ~= nil then
		logWarn("destructorRedundant", "Computed")
	end
	local self = setmetatable({
		scope = scope,
		dependencySet = {},
		dependentSet = {},
		_oldDependencySet = {},
		_processor = processor,
		_value = nil,
		_innerScope = nil
	}, CLASS_METATABLE)
	local self = (self :: any) :: InternalTypes.Computed<T, S>

	table.insert(scope, self)
	self:update()
	
	return self
end

return Computed ]]
_3a83d9b6e14f598dcdf75ad65acdfecb.Children["_57344aa22dd82be83d72380d960ccff0"] = _57344aa22dd82be83d72380d960ccff0
local _57344aa22dd82be83d72380d960ccff0 = nil -- DEALLOCATE PLS :pray:

local _25d9678750294988b9ca84b318338519 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_25d9678750294988b9ca84b318338519.Name = "For"
_25d9678750294988b9ca84b318338519.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	The private generic implementation for all public `For` objects.
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local InternalTypes = require(Package.InternalTypes)
-- Logging
local logError = require(Package.Logging.logError)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local parseError = require(Package.Logging.parseError)
-- State
local peek = require(Package.State.peek)
local isState = require(Package.State.isState)
local Value = require(Package.State.Value)
-- Memory
local doCleanup = require(Package.Memory.doCleanup)
local deriveScope = require(Package.Memory.deriveScope)
local scopePool = require(Package.Memory.scopePool)

local class = {}
class.type = "State"
class.kind = "For"

local CLASS_METATABLE = { __index = class }

--\[\[
	Called when the original table is changed.
\]\]

function class:update(): boolean
	local self = self :: InternalTypes.For<unknown, unknown, unknown, unknown, unknown>
	if self.scope == nil then
		return false
	end
	local outerScope = self.scope :: Types.Scope<unknown>
	local existingInputTable = self._existingInputTable
	local existingOutputTable = self._existingOutputTable
	local existingProcessors = self._existingProcessors
	local newInputTable = peek(self._inputTable)
	local newOutputTable = self._newOutputTable
	local newProcessors = self._newProcessors
	local remainingPairs = self._remainingPairs

	-- clean out main dependency set
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end
	table.clear(self.dependencySet)

	if isState(self._inputTable) then
		local inputTable = self._inputTable :: Types.StateObject<{[unknown]: unknown}> 
		inputTable.dependentSet[self], self.dependencySet[inputTable] = true, true
	end

	if newInputTable ~= existingInputTable then
		for key, value in newInputTable do
			if remainingPairs[key] == nil then
				remainingPairs[key] = {[value] = true}
			else
				remainingPairs[key][value] = true
			end
		end

		-- First, try and reuse processors who match both the key and value of a
		-- remaining pair. This can be done with no recomputation.
		-- NOTE: we also reuse processors with nil output keys here, so long as
		-- they match values. This ensures they don't get recomputed either.
		for tryReuseProcessor in existingProcessors do
			local value = peek(tryReuseProcessor.inputPair).value
			if peek(tryReuseProcessor.outputPair).key == nil then
				for key, remainingValues in remainingPairs do
					if remainingValues[value] ~= nil then
						remainingValues[value] = nil
						tryReuseProcessor.inputPair:set({key = key, value = value})
						newProcessors[tryReuseProcessor] = true
						existingProcessors[tryReuseProcessor] = nil
						break
					end
				end
			else
				local key = peek(tryReuseProcessor.inputPair).key
				local remainingValues = remainingPairs[key]
				if remainingValues ~= nil and remainingValues[value] ~= nil then
					remainingValues[value] = nil
					newProcessors[tryReuseProcessor] = true
					existingProcessors[tryReuseProcessor] = nil
				end
			end
			
		end
		-- Next, try and reuse processors who match the key of a remaining pair.
		-- The value will change but the key will stay stable.
		for tryReuseProcessor in existingProcessors do
			local key = peek(tryReuseProcessor.inputPair).key
			local remainingValues = remainingPairs[key]
			if remainingValues ~= nil then
				local value = next(remainingValues)
				if value ~= nil then
					remainingValues[value] = nil
					tryReuseProcessor.inputPair:set({key = key, value = value})
					newProcessors[tryReuseProcessor] = true
					existingProcessors[tryReuseProcessor] = nil
				end
			end
		end
		-- Next, try and reuse processors who match the value of a remaining pair.
		-- The key will change but the value will stay stable.
		for tryReuseProcessor in existingProcessors do
			local value = peek(tryReuseProcessor.inputPair).value
			for key, remainingValues in remainingPairs do
				if remainingValues[value] ~= nil then
					remainingValues[value] = nil
					tryReuseProcessor.inputPair:set({key = key, value = value})
					newProcessors[tryReuseProcessor] = true
					existingProcessors[tryReuseProcessor] = nil
					break
				end
			end
		end
		-- Finally, try and reuse any remaining processors, even if they do not
		-- match a pair. Both key and value will be changed.
		for tryReuseProcessor in existingProcessors do
			for key, remainingValues in remainingPairs do
				local value = next(remainingValues)
				if value ~= nil then
					remainingValues[value] = nil
					tryReuseProcessor.inputPair:set({key = key, value = value})
					newProcessors[tryReuseProcessor] = true
					existingProcessors[tryReuseProcessor] = nil
					break
				end
			end
		end
		-- By this point, we can be in one of three cases:
		-- 1) some existing processors are left over; no remaining pairs (shrunk)
		-- 2) no existing processors are left over; no remaining pairs (same size)
		-- 3) no existing processors are left over; some remaining pairs (grew)
		-- So, existing processors should be destroyed, and remaining pairs should
		-- be created. This accomodates for table growth and shrinking.
		for unusedProcessor in existingProcessors do
			doCleanup(unusedProcessor.scope)
			scopePool.clearAndGive(unusedProcessor.scope :: any)
		end
		
		for key, remainingValues in remainingPairs do
			for value in remainingValues do
				local innerScope = deriveScope(outerScope)
				local inputPair = Value(innerScope, {key = key, value = value})
				local processOK, outputPair = xpcall(self._processor, parseError, innerScope, inputPair)
				local innerScope = scopePool.giveIfEmpty(innerScope)
				if processOK then
					local processor = {
						inputPair = inputPair,
						outputPair = outputPair,
						scope = innerScope
					}
					newProcessors[processor] = true
				else
					local errorObj = (outputPair :: any) :: InternalTypes.Error
					logErrorNonFatal("callbackError", errorObj)
				end
			end
		end
	end

	for processor in newProcessors do
		local pair = processor.outputPair
		pair.dependentSet[self], self.dependencySet[pair] = true, true
		local key, value = peek(pair).key, peek(pair).value
		if value == nil then
			continue
		end
		if key == nil then
			key = #newOutputTable + 1
		end
		if newOutputTable[key] == nil then
			newOutputTable[key] = value
		else
			logErrorNonFatal("forKeyCollision", nil, key)
		end
	end

	self._existingProcessors = newProcessors
	self._existingOutputTable = newOutputTable
	table.clear(existingOutputTable)
	table.clear(existingProcessors)
	table.clear(remainingPairs)
	self._newProcessors = existingProcessors
	self._newOutputTable = existingOutputTable

	return true
end

--\[\[
	Returns the interior value of this state object.
\]\]
function class:_peek(): unknown
	return self._existingOutputTable
end

function class:get()
	logError("stateGetWasRemoved")
end

function class:destroy()
	if self.scope == nil then
		logError("destroyedTwice", nil, "For")
	end
	self.scope = nil
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end
	for unusedProcessor in self._existingProcessors do
		doCleanup(unusedProcessor.scope)
		scopePool.clearAndGive(unusedProcessor.scope)
	end
end

local function For<KI, KO, VI, VO, S>(
	scope: Types.Scope<S>,
	inputTable: Types.UsedAs<{ [KI]: VI }>,
	processor: (
		Types.Scope<S>,
		Types.StateObject<{key: KI, value: VI}>
	) -> (Types.StateObject<{key: KO?, value: VO?}>)
): Types.For<KO, VO>

	local self = setmetatable({
		scope = scope,
		dependencySet = {},
		dependentSet = {},
		_processor = processor,
		_inputTable = inputTable,
		_existingInputTable = nil,
		_existingOutputTable = {},
		_existingProcessors = {},
		_newOutputTable = {},
		_newProcessors = {},
		_remainingPairs = {}
	}, CLASS_METATABLE)
	local self = (self :: any) :: InternalTypes.For<KI, KO, VI, VO, S>

	table.insert(scope, self)
	self:update()

	return self
end

return For ]]
_3a83d9b6e14f598dcdf75ad65acdfecb.Children["_25d9678750294988b9ca84b318338519"] = _25d9678750294988b9ca84b318338519
local _25d9678750294988b9ca84b318338519 = nil -- DEALLOCATE PLS :pray:

local _ea903761b5dd025a094df2949bc3550f = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_ea903761b5dd025a094df2949bc3550f.Name = "ForKeys"
_ea903761b5dd025a094df2949bc3550f.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Constructs a new For object which maps keys of a table using a `processor`
	function.

	Optionally, a `destructor` function can be specified for cleaning up output.

	Additionally, a `meta` table/value can optionally be returned to pass data
	created when running the processor to the destructor when the created object
	is cleaned up.
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local InternalTypes = require(Package.InternalTypes)
-- State
local For = require(Package.State.For)
local Computed = require(Package.State.Computed)
-- Logging
local parseError = require(Package.Logging.parseError)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local logError = require(Package.Logging.logError)
local logWarn = require(Package.Logging.logWarn)
-- Memory
local doCleanup = require(Package.Memory.doCleanup)

local function ForKeys<KI, KO, V, S>(
	scope: Types.Scope<S>,
	inputTable: Types.UsedAs<{[KI]: V}>,
	processor: (Types.Use, Types.Scope<S>, KI) -> KO,
	destructor: unknown?
): Types.For<KO, V>
	if typeof(inputTable) == "function" then
		logError("scopeMissing", nil, "ForKeys", "myScope:ForKeys(inputTable, function(scope, use, key) ... end)")
	elseif destructor ~= nil then
		logWarn("destructorRedundant", "ForKeys")
	end
	return For(
		scope,
		inputTable,
		function(
			scope: Types.Scope<S>,
			inputPair: Types.StateObject<{key: KI, value: V}>
		)
			local inputKey = Computed(scope, function(use, scope): KI
				return use(inputPair).key
			end)
			local outputKey = Computed(scope, function(use, scope): KO?
				local ok, key = xpcall(processor, parseError, use, scope, use(inputKey))
				if ok then
					return key
				else
					local errorObj = (key :: any) :: InternalTypes.Error
					logErrorNonFatal("callbackError", errorObj)
					doCleanup(scope)
					table.clear(scope)
					return nil
				end
			end)
			return Computed(scope, function(use, scope)
				return {key = use(outputKey), value = use(inputPair).value}
			end)
		end
	)
end

return ForKeys ]]
_3a83d9b6e14f598dcdf75ad65acdfecb.Children["_ea903761b5dd025a094df2949bc3550f"] = _ea903761b5dd025a094df2949bc3550f
local _ea903761b5dd025a094df2949bc3550f = nil -- DEALLOCATE PLS :pray:

local _0bc74a8a7b17d2c48ab3d8ab5a0abb6f = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_0bc74a8a7b17d2c48ab3d8ab5a0abb6f.Name = "ForPairs"
_0bc74a8a7b17d2c48ab3d8ab5a0abb6f.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Constructs a new For object which maps pairs of a table using a `processor`
	function.

	Optionally, a `destructor` function can be specified for cleaning up output.

	Additionally, a `meta` table/value can optionally be returned to pass data
	created when running the processor to the destructor when the created object
	is cleaned up.
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local InternalTypes = require(Package.InternalTypes)
-- State
local For = require(Package.State.For)
local Computed = require(Package.State.Computed)
-- Logging
local parseError = require(Package.Logging.parseError)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local logError = require(Package.Logging.logError)
local logWarn = require(Package.Logging.logWarn)
-- Memory
local doCleanup = require(Package.Memory.doCleanup)

local function ForPairs<KI, KO, VI, VO, S>(
	scope: Types.Scope<S>,
	inputTable: Types.UsedAs<{[KI]: VI}>,
	processor: (Types.Use, Types.Scope<S>, KI, VI) -> (KO, VO),
	destructor: unknown?
): Types.For<KO, VO>
	if typeof(inputTable) == "function" then
		logError("scopeMissing", nil, "ForPairs", "myScope:ForPairs(inputTable, function(scope, use, key, value) ... end)")
	elseif destructor ~= nil then
		logWarn("destructorRedundant", "ForPairs")
	end
	return For(
		scope,
		inputTable,
		function(
			scope: Types.Scope<S>,
			inputPair: Types.StateObject<{key: KI, value: VI}>
		)
			return Computed(scope, function(use, scope): {key: KO?, value: VO?}
				local ok, key, value = xpcall(processor, parseError, use, scope, use(inputPair).key, use(inputPair).value)
				if ok then
					return {key = key, value = value}
				else
					local errorObj = (key :: any) :: InternalTypes.Error
					logErrorNonFatal("callbackError", errorObj)
					doCleanup(scope)
					table.clear(scope)
					return {key = nil, value = nil}
				end
			end)
		end
	)
end

return ForPairs ]]
_3a83d9b6e14f598dcdf75ad65acdfecb.Children["_0bc74a8a7b17d2c48ab3d8ab5a0abb6f"] = _0bc74a8a7b17d2c48ab3d8ab5a0abb6f
local _0bc74a8a7b17d2c48ab3d8ab5a0abb6f = nil -- DEALLOCATE PLS :pray:

local _5750999d14f421b4d6a99b12e6a29191 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_5750999d14f421b4d6a99b12e6a29191.Name = "ForValues"
_5750999d14f421b4d6a99b12e6a29191.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Constructs a new For object which maps values of a table using a `processor`
	function.

	Optionally, a `destructor` function can be specified for cleaning up output.

	Additionally, a `meta` table/value can optionally be returned to pass data
	created when running the processor to the destructor when the created object
	is cleaned up.
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local InternalTypes = require(Package.InternalTypes)
-- State
local For = require(Package.State.For)
local Computed = require(Package.State.Computed)
-- Logging
local parseError = require(Package.Logging.parseError)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local logError = require(Package.Logging.logError)
local logWarn = require(Package.Logging.logWarn)
-- Memory
local doCleanup = require(Package.Memory.doCleanup)

local function ForValues<K, VI, VO, S>(
	scope: Types.Scope<S>,
	inputTable: Types.UsedAs<{[K]: VI}>,
	processor: (Types.Use, Types.Scope<S>, VI) -> VO,
	destructor: unknown?
): Types.For<K, VO>
	if typeof(inputTable) == "function" then
		logError("scopeMissing", nil, "ForValues", "myScope:ForValues(inputTable, function(scope, use, value) ... end)")
	elseif destructor ~= nil then
		logWarn("destructorRedundant", "ForValues")
	end
	return For(
		scope,
		inputTable,
		function(
			scope: Types.Scope<S>,
			inputPair: Types.StateObject<{key: K, value: VI}>
		)
			local inputValue = Computed(scope, function(use, scope): VI
				return use(inputPair).value
			end)
			return Computed(scope, function(use, scope): {key: nil, value: VO?}
				local ok, value = xpcall(processor, parseError, use, scope, use(inputValue))
				if ok then
					return {key = nil, value = value}
				else
					local errorObj = (value :: any) :: InternalTypes.Error
					logErrorNonFatal("callbackError", errorObj)
					doCleanup(scope)
					table.clear(scope)
					return {key = nil, value = nil}
				end
			end)
		end
	)
end

return ForValues ]]
_3a83d9b6e14f598dcdf75ad65acdfecb.Children["_5750999d14f421b4d6a99b12e6a29191"] = _5750999d14f421b4d6a99b12e6a29191
local _5750999d14f421b4d6a99b12e6a29191 = nil -- DEALLOCATE PLS :pray:

local _102a4f4447f600f826108f371822f8d5 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_102a4f4447f600f826108f371822f8d5.Name = "Observer"
_102a4f4447f600f826108f371822f8d5.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Constructs a new state object which can listen for updates on another state
	object.
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local InternalTypes = require(Package.InternalTypes)
local External = require(Package.External)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)
local logWarn = require(Package.Logging.logWarn)
local logError = require(Package.Logging.logError)

local class = {}
class.type = "Observer"

local CLASS_METATABLE = {__index = class}

--\[\[
	Called when the watched state changes value.
\]\]
function class:update(): boolean
	local self = self :: InternalTypes.Observer
	for _, callback in pairs(self._changeListeners) do
		External.doTaskImmediate(callback)
	end
	return false
end

--\[\[
	Adds a change listener. When the watched state changes value, the listener
	will be fired.

	Returns a function which, when called, will disconnect the change listener.
	As long as there is at least one active change listener, this Observer
	will be held in memory, preventing GC, so disconnecting is important.
\]\]
function class:onChange(
	callback: () -> ()
): () -> ()
	local self = self :: InternalTypes.Observer
	local uniqueIdentifier = {}
	self._changeListeners[uniqueIdentifier] = callback
	return function()
		self._changeListeners[uniqueIdentifier] = nil
	end
end

--\[\[
	Similar to `class:onChange()`, however it runs the provided callback
	immediately.
\]\]
function class:onBind(
	callback: () -> ()
): () -> ()
	local self = self :: InternalTypes.Observer
	External.doTaskImmediate(callback)
	return self:onChange(callback)
end

function class:destroy()
	local self = self :: InternalTypes.Observer
	if self.scope == nil then
		logError("destroyedTwice", nil, "Observer")
	end
	self.scope = nil
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end
end

local function Observer(
	scope: Types.Scope<unknown>,
	watching: unknown
): Types.Observer
	if watching == nil then
		logError("scopeMissing", nil, "Observers", "myScope:Observer(watching)")
	end

	local watchingState = typeof(watching) == "table" and (watching :: any).dependentSet ~= nil

	local self = setmetatable({
		scope = scope,
		dependencySet = if watchingState then {[watching] = true} else {},
		dependentSet = {},
		_changeListeners = {}
	}, CLASS_METATABLE)
	local self = (self :: any) :: InternalTypes.Observer
	
	table.insert(scope, self)

	if watchingState then
		local watching: any = watching
		if watching.scope == nil then
			logError(
				"useAfterDestroy",
				nil,
				`The {watching.kind or watching.type or "watched"} object`,
				`the Observer that is watching it`
			)
		elseif whichLivesLonger(scope, self, watching.scope, watching) == "definitely-a" then
			local watching: any = watching
			logWarn(
				"possiblyOutlives",
				`The {watching.kind or watching.type or "watched"} object`,
				`the Observer that is watching it`
			)
		end
		-- add this object to the watched object's dependent set
		watching.dependentSet[self] = true
	end

	return self
end

return Observer ]]
_3a83d9b6e14f598dcdf75ad65acdfecb.Children["_102a4f4447f600f826108f371822f8d5"] = _102a4f4447f600f826108f371822f8d5
local _102a4f4447f600f826108f371822f8d5 = nil -- DEALLOCATE PLS :pray:

local _06df9e5b7dccbf4261407a30095f4374 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_06df9e5b7dccbf4261407a30095f4374.Name = "Value"
_06df9e5b7dccbf4261407a30095f4374.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Constructs and returns objects which can be used to model independent
	reactive state.
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local InternalTypes = require(Package.InternalTypes)
-- Logging
local logError = require(Package.Logging.logError)
-- State
local updateAll = require(Package.State.updateAll)
-- Utility
local isSimilar = require(Package.Utility.isSimilar)

local class = {}
class.type = "State"
class.kind = "Value"

local CLASS_METATABLE = {__index = class}

--\[\[
	Updates the value stored in this State object.

	If `force` is enabled, this will skip equality checks and always update the
	state object and any dependents - use this with care as this can lead to
	unnecessary updates.
\]\]
function class:set(
	newValue: unknown,
	force: boolean?
)
	local self = self :: InternalTypes.Value<unknown, unknown>
	local oldValue = self._value
	if force or not isSimilar(oldValue, newValue) then
		self._value = newValue
		updateAll(self)
	end
end

--\[\[
	Returns the interior value of this state object.
\]\]
function class:_peek(): unknown
	local self = self :: InternalTypes.Value<unknown, unknown>
	return self._value
end

function class:get()
	logError("stateGetWasRemoved")
end

function class:destroy()
	local self = self :: InternalTypes.Value<unknown, unknown>
	if self.scope == nil then
		logError("destroyedTwice", nil, "Value")
	end
	self.scope = nil
end

local function Value<T>(
	scope: Types.Scope<unknown>,
	initialValue: T
): Types.Value<T, any>
	if initialValue == nil and (typeof(scope) ~= "table" or (scope[1] == nil and next(scope) ~= nil)) then
		logError("scopeMissing", nil, "Value", "myScope:Value(initialValue)")
	end

	local self = setmetatable({
		scope = scope,
		dependentSet = {},
		_value = initialValue
	}, CLASS_METATABLE)
	local self = (self :: any) :: InternalTypes.Value<T, any>

	table.insert(scope, self)

	return self
end

return Value ]]
_3a83d9b6e14f598dcdf75ad65acdfecb.Children["_06df9e5b7dccbf4261407a30095f4374"] = _06df9e5b7dccbf4261407a30095f4374
local _06df9e5b7dccbf4261407a30095f4374 = nil -- DEALLOCATE PLS :pray:

local _76d7d87b4c9754d4d05a24e2d1005b05 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_76d7d87b4c9754d4d05a24e2d1005b05.Name = "isState"
_76d7d87b4c9754d4d05a24e2d1005b05.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Returns true if the given value can be assumed to be a valid state object.
\]\]

local function isState(
	target: unknown
): boolean
	if typeof(target) == "table" then
		local target = target :: {_peek: unknown?}
		return typeof(target._peek) == "function"
	end
	return false
end

return isState ]]
_3a83d9b6e14f598dcdf75ad65acdfecb.Children["_76d7d87b4c9754d4d05a24e2d1005b05"] = _76d7d87b4c9754d4d05a24e2d1005b05
local _76d7d87b4c9754d4d05a24e2d1005b05 = nil -- DEALLOCATE PLS :pray:

local _7f14587b2043baf6b3746a920915aa95 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_7f14587b2043baf6b3746a920915aa95.Name = "peek"
_7f14587b2043baf6b3746a920915aa95.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	A common interface for accessing the values of state objects or constants.
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local InternalTypes = require(Package.InternalTypes)
-- State
local isState = require(Package.State.isState)

local function peek<T>(
	target: Types.UsedAs<T>
): T
	if isState(target) then
		return (target :: InternalTypes.StateObject<T>):_peek()
	else
		return target :: T
	end
end

return peek ]]
_3a83d9b6e14f598dcdf75ad65acdfecb.Children["_7f14587b2043baf6b3746a920915aa95"] = _7f14587b2043baf6b3746a920915aa95
local _7f14587b2043baf6b3746a920915aa95 = nil -- DEALLOCATE PLS :pray:

local _3923a24cd8cf6cca1842f5d34fd4d13c = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_3923a24cd8cf6cca1842f5d34fd4d13c.Name = "updateAll"
_3923a24cd8cf6cca1842f5d34fd4d13c.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Given a reactive object, updates all dependent reactive objects.
	Objects are only ever updated after all of their dependencies are updated,
	are only ever updated once, and won't be updated if their dependencies are
	unchanged.
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)

type Descendant = (Types.Dependent & Types.Dependency) | Types.Dependent

-- Credit: https://blog.elttob.uk/2022/11/07/sets-efficient-topological-search.html
local function updateAll(
	root: Types.Dependency
)
	local counters: {[Descendant]: number} = {}
	local flags: {[Descendant]: boolean} = {}
	local queue: {Descendant} = {}
	local queueSize = 0
	local queuePos = 1

	for object in root.dependentSet do
		queueSize += 1
		queue[queueSize] = object
		flags[object] = true
	end

	-- Pass 1: counting up
	while queuePos <= queueSize do
		local next = queue[queuePos]
		local counter = counters[next]
		counters[next] = if counter == nil then 1 else counter + 1
		if (next :: any).dependentSet ~= nil then
			local next = next :: (Types.Dependent & Types.Dependency)
			for object in next.dependentSet do
				queueSize += 1
				queue[queueSize] = object
			end
		end
		queuePos += 1
	end

	-- Pass 2: counting down + processing
	queuePos = 1
	while queuePos <= queueSize do
		local next = queue[queuePos]
		local counter = counters[next] - 1
		counters[next] = counter
		if 
			counter == 0 
			and flags[next] 
			and next.scope ~= nil 
			and next:update() 
			and (next :: any).dependentSet ~= nil 
		then
			local next = next :: (Types.Dependent & Types.Dependency)
			for object in next.dependentSet do
				flags[object] = true
			end
		end
		queuePos += 1
	end
end

return updateAll ]]
_3a83d9b6e14f598dcdf75ad65acdfecb.Children["_3923a24cd8cf6cca1842f5d34fd4d13c"] = _3923a24cd8cf6cca1842f5d34fd4d13c
local _3923a24cd8cf6cca1842f5d34fd4d13c = nil -- DEALLOCATE PLS :pray:

local _cdf3c9273cceda962fd37a207a4a252d = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_cdf3c9273cceda962fd37a207a4a252d.Name = "Types"
_cdf3c9273cceda962fd37a207a4a252d.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Stores common public-facing type information for Fusion APIs.
\]\]

--\[\[
	General use types
\]\]

-- Types that can be expressed as vectors of numbers, and so can be animated.
export type Animatable =
	number |
	CFrame |
	Color3 |
	ColorSequenceKeypoint |
	DateTime |
	NumberRange |
	NumberSequenceKeypoint |
	PhysicalProperties |
	Ray |
	Rect |
	Region3 |
	Region3int16 |
	UDim |
	UDim2 |
	Vector2 |
	Vector2int16 |
	Vector3 |
	Vector3int16

-- A task which can be accepted for cleanup.
export type Task =
	Instance |
	RBXScriptConnection |
	() -> () |
	{destroy: (unknown) -> ()} |
	{Destroy: (unknown) -> ()} |
	{Task}

-- A scope of tasks to clean up.
export type Scope<Constructors> = {unknown} & Constructors

-- An object which uses a scope to dictate how long it lives.
export type ScopedObject = {
	scope: Scope<unknown>?,
	destroy: (any) -> ()
}

-- Script-readable version information.
export type Version = {
	major: number,
	minor: number,
	isRelease: boolean
}

-- An object which stores a value scoped in time.
export type Contextual<T> = {
	type: "Contextual",
	now: (Contextual<T>) -> T,
	is: (Contextual<T>, T) -> ContextualIsMethods
}

type ContextualIsMethods = {
	during: <R, A...>(ContextualIsMethods, (A...) -> R, A...) -> R
}

--\[\[
	Generic reactive graph types
\]\]

-- A graph object which can have dependents.
export type Dependency = ScopedObject & {
	dependentSet: {[Dependent]: unknown}
}

-- A graph object which can have dependencies.
export type Dependent = ScopedObject & {
	update: (Dependent) -> boolean,
	dependencySet: {[Dependency]: unknown}
}

-- An object which stores a piece of reactive state.
export type StateObject<T> = Dependency & {
	type: "State",
	kind: string,
	____phantom_peekType: (never) -> T -- phantom data so this contains a T
}

-- Passing values of this type to `Use` returns `T`.
export type UsedAs<T> = StateObject<T> | T

-- Function signature for use callbacks.
export type Use = <T>(target: UsedAs<T>) -> T

--\[\[
	Specific reactive graph types
\]\]

-- A state object whose value can be set at any time by the user.
export type Value<T, S = T> = StateObject<T> & {
	kind: "State",
 	set: (Value<T, S>, newValue: S, force: boolean?) -> (),
	 ____phantom_setType: (never) -> S -- phantom data so this contains a T
}
export type ValueConstructor = <T>(
	scope: Scope<unknown>,
	initialValue: T
) -> Value<T, any>

-- A state object whose value is derived from other objects using a callback.
export type Computed<T> = StateObject<T> & Dependent & {
	kind: "Computed"
}
export type ComputedConstructor = <T, S>(
	scope: Scope<S>,
	callback: (Use, Scope<S>) -> T
) -> Computed<T>

-- A state object which maps over keys and/or values in another table.
export type For<KO, VO> = StateObject<{[KO]: VO}> & Dependent & {
	kind: "For"
}
export type ForPairsConstructor =  <KI, KO, VI, VO, S>(
	scope: Scope<S>,
	inputTable: UsedAs<{[KI]: VI}>,
	processor: (Use, Scope<S>, key: KI, value: VI) -> (KO, VO)
) -> For<KO, VO>
export type ForKeysConstructor =  <KI, KO, V, S>(
	scope: Scope<S>,
	inputTable: UsedAs<{[KI]: V}>,
	processor: (Use, Scope<S>, key: KI) -> KO
) -> For<KO, V>
export type ForValuesConstructor =  <K, VI, VO, S>(
	scope: Scope<S>,
	inputTable: UsedAs<{[K]: VI}>,
	processor: (Use, Scope<S>, value: VI) -> VO
) -> For<K, VO>

-- An object which can listen for updates on another state object.
export type Observer = Dependent & {
	type: "Observer",
	onChange: (Observer, callback: () -> ()) -> (() -> ()),
	onBind: (Observer, callback: () -> ()) -> (() -> ())
}
export type ObserverConstructor = (
	scope: Scope<unknown>,
	watching: unknown
) -> Observer

-- A state object which follows another state object using tweens.
export type Tween<T> = StateObject<T> & Dependent & {
	kind: "Tween"
}
export type TweenConstructor = <T>(
	scope: Scope<unknown>,
	goalState: UsedAs<T>,
	tweenInfo: UsedAs<TweenInfo>?
) -> Tween<T>

-- A state object which follows another state object using spring simulation.
export type Spring<T> = StateObject<T> & Dependent & {
	kind: "Spring",
	setPosition: (Spring<T>, newPosition: T) -> (),
	setVelocity: (Spring<T>, newVelocity: T) -> (),
	addVelocity: (Spring<T>, deltaVelocity: T) -> ()
}
export type SpringConstructor = <T>(
	scope: Scope<unknown>,
	goalState: UsedAs<T>,
	speed: UsedAs<number>?,
	damping: UsedAs<number>?
) -> Spring<T>

--\[\[
	Instance related types
\]\]

-- Denotes children instances in an instance or component's property table.
export type SpecialKey = {
	type: "SpecialKey",
	kind: string,
	stage: "self" | "descendants" | "ancestor" | "observer",
	apply: (
		self: SpecialKey,
		scope: Scope<unknown>,
		value: unknown,
		applyTo: Instance
	) -> ()
}

-- A collection of instances that may be parented to another instance.
export type Child = Instance | StateObject<Child> | {[unknown]: Child}

-- A table that defines an instance's properties, handlers and children.
export type PropertyTable = {[string | SpecialKey]: unknown}

export type NewConstructor = (
	scope: Scope<unknown>,
	className: string
) -> (propertyTable: PropertyTable) -> Instance

export type HydrateConstructor = (
	scope: Scope<unknown>,
	target: Instance
) -> (propertyTable: PropertyTable) -> Instance

-- Is there a sane way to write out this type?
-- ... I sure hope so.

export type DeriveScopeConstructor = (<S>(Scope<S>) -> Scope<S>)
	& (<S, A>(Scope<S>, A & {}) -> Scope<S & A>)
	& (<S, A, B>(Scope<S>, A & {}, B & {}) -> Scope<S & A & B>)
	& (<S, A, B, C>(Scope<S>, A & {}, B & {}, C & {}) -> Scope<S & A & B & C>)
	& (<S, A, B, C, D>(Scope<S>, A & {}, B & {}, C & {}, D & {}) -> Scope<S & A & B & C & D>)
	& (<S, A, B, C, D, E>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}) -> Scope<S & A & B & C & D & E>)
	& (<S, A, B, C, D, E, F>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}, F & {}) -> Scope<S & A & B & C & D & E & F>)
	& (<S, A, B, C, D, E, F, G>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}) -> Scope<S & A & B & C & D & E & F & G>)
	& (<S, A, B, C, D, E, F, G, H>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}) -> Scope<S & A & B & C & D & E & F & G & H>)
	& (<S, A, B, C, D, E, F, G, H, I>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}) -> Scope<S & A & B & C & D & E & F & G & H & I>)
	& (<S, A, B, C, D, E, F, G, H, I, J>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}, J & {}) -> Scope<S & A & B & C & D & E & F & G & H & I & J>)
	& (<S, A, B, C, D, E, F, G, H, I, J, K>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}, J & {}, K & {}) -> Scope<S & A & B & C & D & E & F & G & H & I & J & K>)
	& (<S, A, B, C, D, E, F, G, H, I, J, K, L>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}, J & {}, K & {}, L & {}) -> Scope<S & A & B & C & D & E & F & G & H & I & J & K & L>)

export type ScopedConstructor = (() -> Scope<{}>)
	& (<A>(A & {}) -> Scope<A>)
	& (<A, B>(A & {}, B & {}) -> Scope<A & B>)
	& (<A, B, C>(A & {}, B & {}, C & {}) -> Scope<A & B & C>)
	& (<A, B, C, D>(A & {}, B & {}, C & {}, D & {}) -> Scope<A & B & C & D>)
	& (<A, B, C, D, E>(A & {}, B & {}, C & {}, D & {}, E & {}) -> Scope<A & B & C & D & E>)
	& (<A, B, C, D, E, F>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}) -> Scope<A & B & C & D & E & F>)
	& (<A, B, C, D, E, F, G>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}) -> Scope<A & B & C & D & E & F & G>)
	& (<A, B, C, D, E, F, G, H>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}) -> Scope<A & B & C & D & E & F & G & H>)
	& (<A, B, C, D, E, F, G, H, I>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}) -> Scope<A & B & C & D & E & F & G & H & I>)
	& (<A, B, C, D, E, F, G, H, I, J>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}, J & {}) -> Scope<A & B & C & D & E & F & G & H & I & J>)
	& (<A, B, C, D, E, F, G, H, I, J, K>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}, J & {}, K & {}) -> Scope<A & B & C & D & E & F & G & H & I & J & K>)
	& (<A, B, C, D, E, F, G, H, I, J, K, L>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}, J & {}, K & {}, L & {}) -> Scope<A & B & C & D & E & F & G & H & I & J & K & L>)

export type ContextualConstructor = <T>(defaultValue: T) -> Contextual<T>

export type Fusion = {
	version: Version,
	Contextual: ContextualConstructor,

	doCleanup: (...unknown) -> (),
	scoped: ScopedConstructor,
	deriveScope: <T>(existing: Scope<T>) -> Scope<T>,

	peek: Use,
	Value: ValueConstructor,
	Computed: ComputedConstructor,
	ForPairs: ForPairsConstructor,
	ForKeys: ForKeysConstructor,
	ForValues: ForValuesConstructor,
	Observer: ObserverConstructor,

	Tween: TweenConstructor,
	Spring: SpringConstructor,

	New: NewConstructor,
	Hydrate: HydrateConstructor,

	Ref: SpecialKey,
	Children: SpecialKey,
	Out: (propertyName: string) -> SpecialKey,
	OnEvent: (eventName: string) -> SpecialKey,
	OnChange: (propertyName: string) -> SpecialKey,
	Attribute: (attributeName: string) -> SpecialKey,
	AttributeChange: (attributeName: string) -> SpecialKey,
	AttributeOut: (attributeName: string) -> SpecialKey,
	
}

return nil ]]
_d56864cbc3c61714243504ffab872304.Children["_cdf3c9273cceda962fd37a207a4a252d"] = _cdf3c9273cceda962fd37a207a4a252d
local _cdf3c9273cceda962fd37a207a4a252d = nil -- DEALLOCATE PLS :pray:

local _8ba60ba5cb83255462879f0cd2a5a14a = { ClassName = "Folder", Children = {}, Properties = {} }
_8ba60ba5cb83255462879f0cd2a5a14a.Name = "Utility"
_d56864cbc3c61714243504ffab872304.Children["_8ba60ba5cb83255462879f0cd2a5a14a"] = _8ba60ba5cb83255462879f0cd2a5a14a
local _8ba60ba5cb83255462879f0cd2a5a14a = nil -- DEALLOCATE PLS :pray:
local _4503315f1267ef1ecaeadd1397fda876 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_4503315f1267ef1ecaeadd1397fda876.Name = "Contextual"
_4503315f1267ef1ecaeadd1397fda876.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
    Time-based contextual values, to allow for transparently passing values down
	the call stack.
\]\]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local InternalTypes = require(Package.InternalTypes)
-- Logging
local logError = require(Package.Logging.logError)
local parseError = require(Package.Logging.parseError)

local class = {}
class.type = "Contextual"

local CLASS_METATABLE = {__index = class}
local WEAK_KEYS_METATABLE = {__mode = "k"}

--\[\[
	Returns the current value of this contextual.
\]\]
function class:now(): unknown
	local self = self :: InternalTypes.Contextual<unknown>
	local thread = coroutine.running()
	local value = self._valuesNow[thread]
	if typeof(value) ~= "table" then
		return self._defaultValue
	else
		return value.value
	end
end

--\[\[
	Temporarily assigns a value to this contextual.
\]\]
function class:is(
	newValue: unknown
)
	-- Methods use colon `:` syntax for consistency and autocomplete but we
	-- actually want them to operate on the `self` from this outer lexical scope
	local outerSelf = self :: InternalTypes.Contextual<unknown>
	local methods = {}
	
	function methods:during<T, A...>(
		callback: (A...) -> T,
		...: A...
	): T
		local thread = coroutine.running()
		local prevValue = outerSelf._valuesNow[thread]
		-- Storing the value in this format allows us to distinguish storing
		-- `nil` from not calling `:during()` at all.
		outerSelf._valuesNow[thread] = { value = newValue }
		local ok, value = xpcall(callback, parseError, ...)
		outerSelf._valuesNow[thread] = prevValue
		if not ok then
			logError("callbackError", value :: any)
		end
		return value
	end

	return methods
end

local function Contextual<T>(
	defaultValue: T
): Types.Contextual<T>
	local self = setmetatable({
		-- if we held strong references to threads here, then if a thread was
		-- killed before this contextual had a chance to finish executing its
		-- callback, it would be held strongly in this table forever
		_valuesNow = setmetatable({}, WEAK_KEYS_METATABLE),
		_defaultValue = defaultValue
	}, CLASS_METATABLE)
	local self = (self :: any) :: InternalTypes.Contextual<T>

	return self
end

return Contextual ]]
_8ba60ba5cb83255462879f0cd2a5a14a.Children["_4503315f1267ef1ecaeadd1397fda876"] = _4503315f1267ef1ecaeadd1397fda876
local _4503315f1267ef1ecaeadd1397fda876 = nil -- DEALLOCATE PLS :pray:

local _e2d7adbf246e9f04ebd6c1e87d98dd8d = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_e2d7adbf246e9f04ebd6c1e87d98dd8d.Name = "Safe"
_e2d7adbf246e9f04ebd6c1e87d98dd8d.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
    A variant of xpcall() designed for inline usage, letting you define fallback
	values based on caught errors.
\]\]

local Package = script.Parent.Parent

local function Safe<Success, Fail>(
	callbacks: {
		try: () -> Success,
		fallback: (err: unknown) -> Fail
	}
): Success | Fail
	local _, value = xpcall(callbacks.try, callbacks.fallback)
	return value
end

return Safe ]]
_8ba60ba5cb83255462879f0cd2a5a14a.Children["_e2d7adbf246e9f04ebd6c1e87d98dd8d"] = _e2d7adbf246e9f04ebd6c1e87d98dd8d
local _e2d7adbf246e9f04ebd6c1e87d98dd8d = nil -- DEALLOCATE PLS :pray:

local _e2fb08c04665169163fe341f064c6449 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_e2fb08c04665169163fe341f064c6449.Name = "isSimilar"
_e2fb08c04665169163fe341f064c6449.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Implements the 'similarity test' used to determine whether two values have
	a meaningful difference.

	https://elttob.uk/Fusion/0.3/tutorials/best-practices/optimisation/#similarity
\]\]

local function isSimilar(
	a: unknown, 
	b: unknown
): boolean
	local typeA = typeof(a)
	local isTable = typeA == "table"
	local isUserdata = typeA == "userdata"
	return
		if not (isTable or isUserdata) then
			a == b or a ~= a and b ~= b
		elseif typeA == typeof(b) and (isUserdata or table.isfrozen(a :: any) or getmetatable(a :: any) ~= nil) then
			a == b
		else
			false
end

return isSimilar ]]
_8ba60ba5cb83255462879f0cd2a5a14a.Children["_e2fb08c04665169163fe341f064c6449"] = _e2fb08c04665169163fe341f064c6449
local _e2fb08c04665169163fe341f064c6449 = nil -- DEALLOCATE PLS :pray:

local _438d4935423b7834ac82bf3a5f5030fb = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_438d4935423b7834ac82bf3a5f5030fb.Name = "merge"
_438d4935423b7834ac82bf3a5f5030fb.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Attempts to merge a variadic number of tables together.
\]\]

local Package = script.Parent.Parent
local logError = require(Package.Logging.logError)

local function merge(
	overwrite: "none" | "first" | "all",
	into: {[unknown]: unknown},
	from: {[unknown]: unknown}?,
	...: {[unknown]: unknown}
): {[unknown]: unknown}
	if from == nil then
		return into
	else
		for key, value in from do
			if into[key] == nil then
				into[key] = value
			elseif overwrite == "none" then
				logError("mergeConflict", nil, tostring(key))
			end
		end
		return merge(if overwrite == "first" then "none" else overwrite, into, ...)
	end
end

return merge ]]
_8ba60ba5cb83255462879f0cd2a5a14a.Children["_438d4935423b7834ac82bf3a5f5030fb"] = _438d4935423b7834ac82bf3a5f5030fb
local _438d4935423b7834ac82bf3a5f5030fb = nil -- DEALLOCATE PLS :pray:

local _a83d2072a9076bdd921c17525e5e496c = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_a83d2072a9076bdd921c17525e5e496c.Name = "xtypeof"
_a83d2072a9076bdd921c17525e5e496c.Properties.Source = [[ --!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--\[\[
	Extended typeof, designed for identifying custom objects.
	If given a table with a `type` string, returns that.
	Otherwise, returns `typeof()` the argument.
\]\]

local function xtypeof(
	x: unknown
): string
	local typeString = typeof(x)

	if typeString == "table" then
		local x = x :: {type: unknown?}
		if typeof(x.type) == "string" then
			return x.type
		end
	end

	return typeString
end

return xtypeof ]]
_8ba60ba5cb83255462879f0cd2a5a14a.Children["_a83d2072a9076bdd921c17525e5e496c"] = _a83d2072a9076bdd921c17525e5e496c
local _a83d2072a9076bdd921c17525e5e496c = nil -- DEALLOCATE PLS :pray:
getfenv(0).rootTree = _c781ff795ccaae172b8a8013d25039e5
getfenv(0).rootReferent = "_c781ff795ccaae172b8a8013d25039e5"
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

	local rtSource = HttpService:GetAsync(
		"https://raw.githubusercontent.com/techs-sus/rojo-script/master/runtime/lua_sandbox.lua",
		false
	)
	local rootModel, rootReferentsToInstances, rootInstancesToTrees, sourceMap =
		constructInstanceFromTree(rootTree, rootReferent)
	print(`rojo-script: took {os.clock() - start} seconds to construct instance from tree`)

	local function wrappedNS(source: Script | string, parent: Instance, ...)
		if #({...}) ~= 0 then
			error("expected 2 arguments, got " .. 2 + #({...}) .. " arguments")
		end
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
							local scriptInfo = SharedTableRegistry:GetSharedTable(accessToken)
							SharedTableRegistry:SetSharedTable(accessToken, nil)
							local rootTree = scriptInfo.tree

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

							%s

							-- environment tampering
							setfenv(0, runtime.getPatchedEnvironment(script))

							warn("environment tampering is not done yet")
						end)()
						--- end rojo-script environment tampering ---\n
					]],
					accessToken,
					constructorSource,
					rtSource
				)
				SharedTableRegistry:SetSharedTable(
					accessToken,
					SharedTable.new({ tree = rootInstancesToTrees[source] })
				)
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
		if runtime.loadedModules[script] then
			return unpack(runtime.loadedModules[script])
		end
		if typeof(script) == "number" then
			return require(script)
		end
		if not script:IsA("ModuleScript") then
			return error("Instance is not a ModuleScript")
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

	function runtime.main()
		-- this is still unsafe thanks to fake->real not being added yet
		local safeContainer = Instance.new("Script")
		safeContainer.Name = "Script"
		rootModel.Parent = safeContainer
		safeContainer.Parent = workspace
		-- getchildren is impossible for rojo projects
		for _, instance in rootModel:GetDescendants() do
			if instance:IsA("Script") and not instance.Disabled then
				runScript(instance)
			end
		end
	end

	runtime.runScript = runScript
end

runtime.main()