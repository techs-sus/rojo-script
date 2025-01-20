-- rojo-script runtime 'lua-sandbox'
script:Destroy();script=nil
local _9df0b325193e84994e6b9cc5ae584d22 = { ClassName = "Model", Children = {}, Properties = {} }
_9df0b325193e84994e6b9cc5ae584d22.Name = "DataModel"
local _4939180de2039ab164a0b6fd3ff1aed2 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_4939180de2039ab164a0b6fd3ff1aed2.Name = "Roact"
_4939180de2039ab164a0b6fd3ff1aed2.Properties.Source = [[ --~strict
--\[\[
	Packages up the internals of Roact and exposes a public API for it.
\]\]

local GlobalConfig = require(script.GlobalConfig)
local createReconciler = require(script.createReconciler)
local createReconcilerCompat = require(script.createReconcilerCompat)
local RobloxRenderer = require(script.RobloxRenderer)
local strict = require(script.strict)
local Binding = require(script.Binding)

local robloxReconciler = createReconciler(RobloxRenderer)
local reconcilerCompat = createReconcilerCompat(robloxReconciler)

local Roact = strict({
	Component = require(script.Component),
	createElement = require(script.createElement),
	createFragment = require(script.createFragment),
	oneChild = require(script.oneChild),
	PureComponent = require(script.PureComponent),
	None = require(script.None),
	Portal = require(script.Portal),
	createRef = require(script.createRef),
	forwardRef = require(script.forwardRef),
	createBinding = Binding.create,
	joinBindings = Binding.join,
	createContext = require(script.createContext),

	Change = require(script.PropMarkers.Change),
	Children = require(script.PropMarkers.Children),
	Event = require(script.PropMarkers.Event),
	Ref = require(script.PropMarkers.Ref),

	mount = robloxReconciler.mountVirtualTree,
	unmount = robloxReconciler.unmountVirtualTree,
	update = robloxReconciler.updateVirtualTree,

	reify = reconcilerCompat.reify,
	teardown = reconcilerCompat.teardown,
	reconcile = reconcilerCompat.reconcile,

	setGlobalConfig = GlobalConfig.set,

	-- APIs that may change in the future without warning
	UNSTABLE = {},
})

return Roact ]]
_9df0b325193e84994e6b9cc5ae584d22.Children["_4939180de2039ab164a0b6fd3ff1aed2"] = _4939180de2039ab164a0b6fd3ff1aed2
local _4939180de2039ab164a0b6fd3ff1aed2 = nil -- DEALLOCATE PLS :pray:
local _75ed4e604838b78af219b567b2a2d6c8 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_75ed4e604838b78af219b567b2a2d6c8.Name = "Binding"
_75ed4e604838b78af219b567b2a2d6c8.Properties.Source = [[ local createSignal = require(script.Parent.createSignal)
local Symbol = require(script.Parent.Symbol)
local Type = require(script.Parent.Type)

local config = require(script.Parent.GlobalConfig).get()

local BindingImpl = Symbol.named("BindingImpl")

local BindingInternalApi = {}

local bindingPrototype = {}

function bindingPrototype:getValue()
	return BindingInternalApi.getValue(self)
end

function bindingPrototype:map(predicate)
	return BindingInternalApi.map(self, predicate)
end

local BindingPublicMeta = {
	__index = bindingPrototype,
	__tostring = function(self)
		return string.format("RoactBinding(%s)", tostring(self:getValue()))
	end,
}

function BindingInternalApi.update(binding, newValue)
	return binding[BindingImpl].update(newValue)
end

function BindingInternalApi.subscribe(binding, callback)
	return binding[BindingImpl].subscribe(callback)
end

function BindingInternalApi.getValue(binding)
	return binding[BindingImpl].getValue()
end

function BindingInternalApi.create(initialValue)
	local impl = {
		value = initialValue,
		changeSignal = createSignal(),
	}

	function impl.subscribe(callback)
		return impl.changeSignal:subscribe(callback)
	end

	function impl.update(newValue)
		impl.value = newValue
		impl.changeSignal:fire(newValue)
	end

	function impl.getValue()
		return impl.value
	end

	return setmetatable({
		[Type] = Type.Binding,
		[BindingImpl] = impl,
	}, BindingPublicMeta), impl.update
end

function BindingInternalApi.map(upstreamBinding, predicate)
	if config.typeChecks then
		assert(Type.of(upstreamBinding) == Type.Binding, "Expected arg #1 to be a binding")
		assert(typeof(predicate) == "function", "Expected arg #1 to be a function")
	end

	local impl = {}

	function impl.subscribe(callback)
		return BindingInternalApi.subscribe(upstreamBinding, function(newValue)
			callback(predicate(newValue))
		end)
	end

	function impl.update(_newValue)
		error("Bindings created by Binding:map(fn) cannot be updated directly", 2)
	end

	function impl.getValue()
		return predicate(upstreamBinding:getValue())
	end

	return setmetatable({
		[Type] = Type.Binding,
		[BindingImpl] = impl,
	}, BindingPublicMeta)
end

function BindingInternalApi.join(upstreamBindings)
	if config.typeChecks then
		assert(typeof(upstreamBindings) == "table", "Expected arg #1 to be of type table")

		for key, value in pairs(upstreamBindings) do
			if Type.of(value) ~= Type.Binding then
				local message = ("Expected arg #1 to contain only bindings, but key %q had a non-binding value"):format(
					tostring(key)
				)
				error(message, 2)
			end
		end
	end

	local impl = {}

	local function getValue()
		local value = {}

		for key, upstream in pairs(upstreamBindings) do
			value[key] = upstream:getValue()
		end

		return value
	end

	function impl.subscribe(callback)
		local disconnects = {}

		for key, upstream in pairs(upstreamBindings) do
			disconnects[key] = BindingInternalApi.subscribe(upstream, function(_newValue)
				callback(getValue())
			end)
		end

		return function()
			if disconnects == nil then
				return
			end

			for _, disconnect in pairs(disconnects) do
				disconnect()
			end

			disconnects = nil :: any
		end
	end

	function impl.update(_newValue)
		error("Bindings created by joinBindings(...) cannot be updated directly", 2)
	end

	function impl.getValue()
		return getValue()
	end

	return setmetatable({
		[Type] = Type.Binding,
		[BindingImpl] = impl,
	}, BindingPublicMeta)
end

return BindingInternalApi ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_75ed4e604838b78af219b567b2a2d6c8"] = _75ed4e604838b78af219b567b2a2d6c8
local _75ed4e604838b78af219b567b2a2d6c8 = nil -- DEALLOCATE PLS :pray:

local _a35c763fe2aa5bbae90536fd32bbbb4c = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_a35c763fe2aa5bbae90536fd32bbbb4c.Name = "Binding.spec"
_a35c763fe2aa5bbae90536fd32bbbb4c.Properties.Source = [[ return function()
	local createSpy = require(script.Parent.createSpy)
	local Type = require(script.Parent.Type)
	local GlobalConfig = require(script.Parent.GlobalConfig)

	local Binding = require(script.Parent.Binding)

	describe("Binding.create", function()
		it("should return a Binding object and an update function", function()
			local binding, update = Binding.create(1)

			expect(Type.of(binding)).to.equal(Type.Binding)
			expect(typeof(update)).to.equal("function")
		end)

		it("should support tostring on bindings", function()
			local binding, update = Binding.create(1)
			expect(tostring(binding)).to.equal("RoactBinding(1)")

			update("foo")
			expect(tostring(binding)).to.equal("RoactBinding(foo)")
		end)
	end)

	describe("Binding object", function()
		it("should provide a getter and setter", function()
			local binding, update = Binding.create(1)

			expect(binding:getValue()).to.equal(1)

			update(3)

			expect(binding:getValue()).to.equal(3)
		end)

		it("should let users subscribe and unsubscribe to its updates", function()
			local binding, update = Binding.create(1)

			local spy = createSpy()
			local disconnect = Binding.subscribe(binding, spy.value)

			expect(spy.callCount).to.equal(0)

			update(2)

			expect(spy.callCount).to.equal(1)
			spy:assertCalledWith(2)

			disconnect()
			update(3)

			expect(spy.callCount).to.equal(1)
		end)
	end)

	describe("Mapped bindings", function()
		it("should be composable", function()
			local word, updateWord = Binding.create("hi")

			local wordLength = word:map(string.len)
			local isEvenLength = wordLength:map(function(value)
				return value % 2 == 0
			end)

			expect(word:getValue()).to.equal("hi")
			expect(wordLength:getValue()).to.equal(2)
			expect(isEvenLength:getValue()).to.equal(true)

			updateWord("sup")

			expect(word:getValue()).to.equal("sup")
			expect(wordLength:getValue()).to.equal(3)
			expect(isEvenLength:getValue()).to.equal(false)
		end)

		it("should cascade updates when subscribed", function()
			-- base binding
			local word, updateWord = Binding.create("hi")

			local wordSpy = createSpy()
			local disconnectWord = Binding.subscribe(word, wordSpy.value)

			-- binding -> base binding
			local length = word:map(string.len)

			local lengthSpy = createSpy()
			local disconnectLength = Binding.subscribe(length, lengthSpy.value)

			-- binding -> binding -> base binding
			local isEvenLength = length:map(function(value)
				return value % 2 == 0
			end)

			local isEvenLengthSpy = createSpy()
			local disconnectIsEvenLength = Binding.subscribe(isEvenLength, isEvenLengthSpy.value)

			expect(wordSpy.callCount).to.equal(0)
			expect(lengthSpy.callCount).to.equal(0)
			expect(isEvenLengthSpy.callCount).to.equal(0)

			updateWord("nice")

			expect(wordSpy.callCount).to.equal(1)
			wordSpy:assertCalledWith("nice")

			expect(lengthSpy.callCount).to.equal(1)
			lengthSpy:assertCalledWith(4)

			expect(isEvenLengthSpy.callCount).to.equal(1)
			isEvenLengthSpy:assertCalledWith(true)

			disconnectWord()
			disconnectLength()
			disconnectIsEvenLength()

			updateWord("goodbye")

			expect(wordSpy.callCount).to.equal(1)
			expect(isEvenLengthSpy.callCount).to.equal(1)
			expect(lengthSpy.callCount).to.equal(1)
		end)

		it("should throw when updated directly", function()
			local source = Binding.create(1)
			local mapped = source:map(function(v)
				return v
			end)

			expect(function()
				Binding.update(mapped, 5)
			end).to.throw()
		end)
	end)

	describe("Binding.join", function()
		it("should have getValue", function()
			local binding1 = Binding.create(1)
			local binding2 = Binding.create(2)
			local binding3 = Binding.create(3)

			local joinedBinding = Binding.join({
				binding1,
				binding2,
				foo = binding3,
			})

			local bindingValue = joinedBinding:getValue()
			expect(bindingValue).to.be.a("table")
			expect(bindingValue[1]).to.equal(1)
			expect(bindingValue[2]).to.equal(2)
			expect(bindingValue.foo).to.equal(3)
		end)

		it("should update when any one of the subscribed bindings updates", function()
			local binding1, update1 = Binding.create(1)
			local binding2, update2 = Binding.create(2)
			local binding3, update3 = Binding.create(3)

			local joinedBinding = Binding.join({
				binding1,
				binding2,
				foo = binding3,
			})

			local spy = createSpy()
			Binding.subscribe(joinedBinding, spy.value)

			expect(spy.callCount).to.equal(0)

			update1(3)
			expect(spy.callCount).to.equal(1)

			local args = spy:captureValues("value")
			expect(args.value).to.be.a("table")
			expect(args.value[1]).to.equal(3)
			expect(args.value[2]).to.equal(2)
			expect(args.value["foo"]).to.equal(3)

			update2(4)
			expect(spy.callCount).to.equal(2)

			args = spy:captureValues("value")
			expect(args.value).to.be.a("table")
			expect(args.value[1]).to.equal(3)
			expect(args.value[2]).to.equal(4)
			expect(args.value["foo"]).to.equal(3)

			update3(8)
			expect(spy.callCount).to.equal(3)

			args = spy:captureValues("value")
			expect(args.value).to.be.a("table")
			expect(args.value[1]).to.equal(3)
			expect(args.value[2]).to.equal(4)
			expect(args.value["foo"]).to.equal(8)
		end)

		it("should disconnect from all upstream bindings", function()
			local binding1, update1 = Binding.create(1)
			local binding2, update2 = Binding.create(2)

			local joined = Binding.join({ binding1, binding2 })

			local spy = createSpy()
			local disconnect = Binding.subscribe(joined, spy.value)

			expect(spy.callCount).to.equal(0)

			update1(3)
			expect(spy.callCount).to.equal(1)

			update2(3)
			expect(spy.callCount).to.equal(2)

			disconnect()
			update1(4)
			expect(spy.callCount).to.equal(2)

			update2(2)
			expect(spy.callCount).to.equal(2)

			local value = joined:getValue()
			expect(value[1]).to.equal(4)
			expect(value[2]).to.equal(2)
		end)

		it("should be okay with calling disconnect multiple times", function()
			local joined = Binding.join({})

			local disconnect = Binding.subscribe(joined, function() end)

			disconnect()
			disconnect()
		end)

		it("should throw if updated directly", function()
			local joined = Binding.join({})

			expect(function()
				Binding.update(joined, 0)
			end)
		end)

		it("should throw when a non-table value is passed", function()
			GlobalConfig.scoped({
				typeChecks = true,
			}, function()
				expect(function()
					Binding.join("hi")
				end).to.throw()
			end)
		end)

		it("should throw when a non-binding value is passed via table", function()
			GlobalConfig.scoped({
				typeChecks = true,
			}, function()
				expect(function()
					local binding = Binding.create(123)

					Binding.join({
						binding,
						"abcde",
					})
				end).to.throw()
			end)
		end)
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_a35c763fe2aa5bbae90536fd32bbbb4c"] = _a35c763fe2aa5bbae90536fd32bbbb4c
local _a35c763fe2aa5bbae90536fd32bbbb4c = nil -- DEALLOCATE PLS :pray:

local _763f72be355b1770902b6a0a302baa23 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_763f72be355b1770902b6a0a302baa23.Name = "Component"
_763f72be355b1770902b6a0a302baa23.Properties.Source = [[ local assign = require(script.Parent.assign)
local ComponentLifecyclePhase = require(script.Parent.ComponentLifecyclePhase)
local Type = require(script.Parent.Type)
local Symbol = require(script.Parent.Symbol)
local invalidSetStateMessages = require(script.Parent.invalidSetStateMessages)
local internalAssert = require(script.Parent.internalAssert)

local config = require(script.Parent.GlobalConfig).get()

--\[\[
	Calling setState during certain lifecycle allowed methods has the potential
	to create an infinitely updating component. Rather than time out, we exit
	with an error if an unreasonable number of self-triggering updates occur
\]\]
local MAX_PENDING_UPDATES = 100

local InternalData = Symbol.named("InternalData")

local componentMissingRenderMessage = \[\[
The component %q is missing the `render` method.
`render` must be defined when creating a Roact component!\]\]

local tooManyUpdatesMessage = \[\[
The component %q has reached the setState update recursion limit.
When using `setState` in `didUpdate`, make sure that it won't repeat infinitely!\]\]

local componentClassMetatable = {}

function componentClassMetatable:__tostring()
	return self.__componentName
end

local Component = {}
setmetatable(Component, componentClassMetatable)

Component[Type] = Type.StatefulComponentClass
Component.__index = Component
Component.__componentName = "Component"

--\[\[
	A method called by consumers of Roact to create a new component class.
	Components can not be extended beyond this point, with the exception of
	PureComponent.
\]\]
function Component:extend(name)
	if config.typeChecks then
		assert(Type.of(self) == Type.StatefulComponentClass, "Invalid `self` argument to `extend`.")
		assert(typeof(name) == "string", "Component class name must be a string")
	end

	local class = {}

	for key, value in pairs(self) do
		-- Roact opts to make consumers use composition over inheritance, which
		-- lines up with React.
		-- https://reactjs.org/docs/composition-vs-inheritance.html
		if key ~= "extend" then
			class[key] = value
		end
	end

	class[Type] = Type.StatefulComponentClass
	class.__index = class
	class.__componentName = name

	setmetatable(class, componentClassMetatable)

	return class
end

function Component:__getDerivedState(incomingProps, incomingState)
	if config.internalTypeChecks then
		internalAssert(Type.of(self) == Type.StatefulComponentInstance, "Invalid use of `__getDerivedState`")
	end

	local internalData = self[InternalData]
	local componentClass = internalData.componentClass

	if componentClass.getDerivedStateFromProps ~= nil then
		local derivedState = componentClass.getDerivedStateFromProps(incomingProps, incomingState)

		if derivedState ~= nil then
			if config.typeChecks then
				assert(typeof(derivedState) == "table", "getDerivedStateFromProps must return a table!")
			end

			return derivedState
		end
	end

	return nil
end

function Component:setState(mapState)
	if config.typeChecks then
		assert(Type.of(self) == Type.StatefulComponentInstance, "Invalid `self` argument to `extend`.")
	end

	local internalData = self[InternalData]
	local lifecyclePhase = internalData.lifecyclePhase

	--\[\[
		When preparing to update, render, or unmount, it is not safe
		to call `setState` as it will interfere with in-flight updates. It's
		also disallowed during unmounting
	\]\]
	if
		lifecyclePhase == ComponentLifecyclePhase.ShouldUpdate
		or lifecyclePhase == ComponentLifecyclePhase.WillUpdate
		or lifecyclePhase == ComponentLifecyclePhase.Render
	then
		local messageTemplate = invalidSetStateMessages[internalData.lifecyclePhase]

		local message = messageTemplate:format(tostring(internalData.componentClass))
		error(message, 2)
	elseif lifecyclePhase == ComponentLifecyclePhase.WillUnmount then
		-- Should not print error message. See https://github.com/facebook/react/pull/22114
		return
	end

	local pendingState = internalData.pendingState

	local partialState
	if typeof(mapState) == "function" then
		partialState = mapState(pendingState or self.state, self.props)

		-- Abort the state update if the given state updater function returns nil
		if partialState == nil then
			return
		end
	elseif typeof(mapState) == "table" then
		partialState = mapState
	else
		error("Invalid argument to setState, expected function or table", 2)
	end

	local newState
	if pendingState ~= nil then
		newState = assign(pendingState, partialState)
	else
		newState = assign({}, self.state, partialState)
	end

	if lifecyclePhase == ComponentLifecyclePhase.Init then
		-- If `setState` is called in `init`, we can skip triggering an update!
		local derivedState = self:__getDerivedState(self.props, newState)
		self.state = assign(newState, derivedState)
	elseif
		lifecyclePhase == ComponentLifecyclePhase.DidMount
		or lifecyclePhase == ComponentLifecyclePhase.DidUpdate
		or lifecyclePhase == ComponentLifecyclePhase.ReconcileChildren
	then
		--\[\[
			During certain phases of the component lifecycle, it's acceptable to
			allow `setState` but defer the update until we're done with ones in flight.
			We do this by collapsing it into any pending updates we have.
		\]\]
		local derivedState = self:__getDerivedState(self.props, newState)
		internalData.pendingState = assign(newState, derivedState)
	elseif lifecyclePhase == ComponentLifecyclePhase.Idle then
		-- Outside of our lifecycle, the state update is safe to make immediately
		self:__update(nil, newState)
	else
		local messageTemplate = invalidSetStateMessages.default

		local message = messageTemplate:format(tostring(internalData.componentClass))

		error(message, 2)
	end
end

--\[\[
	Returns the stack trace of where the element was created that this component
	instance's properties are based on.

	Intended to be used primarily by diagnostic tools.
\]\]
function Component:getElementTraceback()
	return self[InternalData].virtualNode.currentElement.source
end

--\[\[
	Returns a snapshot of this component given the current props and state. Must
	be overridden by consumers of Roact and should be a pure function with
	regards to props and state.

	TODO (#199): Accept props and state as arguments.
\]\]
function Component:render()
	local internalData = self[InternalData]

	local message = componentMissingRenderMessage:format(tostring(internalData.componentClass))

	error(message, 0)
end

--\[\[
	Retrieves the context value corresponding to the given key. Can return nil
	if a requested context key is not present
\]\]
function Component:__getContext(key)
	if config.internalTypeChecks then
		internalAssert(Type.of(self) == Type.StatefulComponentInstance, "Invalid use of `__getContext`")
		internalAssert(key ~= nil, "Context key cannot be nil")
	end

	local virtualNode = self[InternalData].virtualNode
	local context = virtualNode.context

	return context[key]
end

--\[\[
	Adds a new context entry to this component's context table (which will be
	passed down to child components).
\]\]
function Component:__addContext(key, value)
	if config.internalTypeChecks then
		internalAssert(Type.of(self) == Type.StatefulComponentInstance, "Invalid use of `__addContext`")
	end
	local virtualNode = self[InternalData].virtualNode

	-- Make sure we store a reference to the component's original, unmodified
	-- context the virtual node. In the reconciler, we'll restore the original
	-- context if we need to replace the node (this happens when a node gets
	-- re-rendered as a different component)
	if virtualNode.originalContext == nil then
		virtualNode.originalContext = virtualNode.context
	end

	-- Build a new context table on top of the existing one, then apply it to
	-- our virtualNode
	local existing = virtualNode.context
	virtualNode.context = assign({}, existing, { [key] = value })
end

--\[\[
	Performs property validation if the static method validateProps is declared.
	validateProps should follow assert's expected arguments:
	(false, message: string) | true. The function may return a message in the
	true case; it will be ignored. If this fails, the function will throw the
	error.
\]\]
function Component:__validateProps(props)
	if not config.propValidation then
		return
	end

	local validator = self[InternalData].componentClass.validateProps

	if validator == nil then
		return
	end

	if typeof(validator) ~= "function" then
		error(
			("validateProps must be a function, but it is a %s.\nCheck the definition of the component %q."):format(
				typeof(validator),
				self.__componentName
			)
		)
	end

	local success, failureReason = validator(props)

	if not success then
		failureReason = failureReason or "<Validator function did not supply a message>"
		error(
			("Property validation failed in %s: %s\n\n%s"):format(
				self.__componentName,
				tostring(failureReason),
				self:getElementTraceback() or "<enable element tracebacks>"
			),
			0
		)
	end
end

--\[\[
	An internal method used by the reconciler to construct a new component
	instance and attach it to the given virtualNode.
\]\]
function Component:__mount(reconciler, virtualNode)
	if config.internalTypeChecks then
		internalAssert(Type.of(self) == Type.StatefulComponentClass, "Invalid use of `__mount`")
		internalAssert(Type.of(virtualNode) == Type.VirtualNode, "Expected arg #2 to be of type VirtualNode")
	end

	local currentElement = virtualNode.currentElement
	local hostParent = virtualNode.hostParent

	-- Contains all the information that we want to keep from consumers of
	-- Roact, or even other parts of the codebase like the reconciler.
	local internalData = {
		reconciler = reconciler,
		virtualNode = virtualNode,
		componentClass = self,
		lifecyclePhase = ComponentLifecyclePhase.Init,
		pendingState = nil,
	}

	local instance = {
		[Type] = Type.StatefulComponentInstance,
		[InternalData] = internalData,
	}

	setmetatable(instance, self)

	virtualNode.instance = instance

	local props = currentElement.props

	if self.defaultProps ~= nil then
		props = assign({}, self.defaultProps, props)
	end

	instance:__validateProps(props)

	instance.props = props

	local newContext = assign({}, virtualNode.legacyContext)
	instance._context = newContext

	instance.state = assign({}, instance:__getDerivedState(instance.props, {}))

	if instance.init ~= nil then
		instance:init(instance.props)
		assign(instance.state, instance:__getDerivedState(instance.props, instance.state))
	end

	-- It's possible for init() to redefine _context!
	virtualNode.legacyContext = instance._context

	internalData.lifecyclePhase = ComponentLifecyclePhase.Render
	local renderResult = instance:render()

	internalData.lifecyclePhase = ComponentLifecyclePhase.ReconcileChildren
	reconciler.updateVirtualNodeWithRenderResult(virtualNode, hostParent, renderResult)

	if instance.didMount ~= nil then
		internalData.lifecyclePhase = ComponentLifecyclePhase.DidMount
		instance:didMount()
	end

	if internalData.pendingState ~= nil then
		-- __update will handle pendingState, so we don't pass any new element or state
		instance:__update(nil, nil)
	end

	internalData.lifecyclePhase = ComponentLifecyclePhase.Idle
end

--\[\[
	Internal method used by the reconciler to clean up any resources held by
	this component instance.
\]\]
function Component:__unmount()
	if config.internalTypeChecks then
		internalAssert(Type.of(self) == Type.StatefulComponentInstance, "Invalid use of `__unmount`")
	end

	local internalData = self[InternalData]
	local virtualNode = internalData.virtualNode
	local reconciler = internalData.reconciler

	if self.willUnmount ~= nil then
		internalData.lifecyclePhase = ComponentLifecyclePhase.WillUnmount
		self:willUnmount()
	end

	for _, childNode in pairs(virtualNode.children) do
		reconciler.unmountVirtualNode(childNode)
	end
end

--\[\[
	Internal method used by setState (to trigger updates based on state) and by
	the reconciler (to trigger updates based on props)

	Returns true if the update was completed, false if it was cancelled by shouldUpdate
\]\]
function Component:__update(updatedElement, updatedState)
	if config.internalTypeChecks then
		internalAssert(Type.of(self) == Type.StatefulComponentInstance, "Invalid use of `__update`")
		internalAssert(
			Type.of(updatedElement) == Type.Element or updatedElement == nil,
			"Expected arg #1 to be of type Element or nil"
		)
		internalAssert(
			typeof(updatedState) == "table" or updatedState == nil,
			"Expected arg #2 to be of type table or nil"
		)
	end

	local internalData = self[InternalData]
	local componentClass = internalData.componentClass

	local newProps = self.props
	if updatedElement ~= nil then
		newProps = updatedElement.props

		if componentClass.defaultProps ~= nil then
			newProps = assign({}, componentClass.defaultProps, newProps)
		end

		self:__validateProps(newProps)
	end

	local updateCount = 0
	repeat
		local finalState
		local pendingState = nil

		-- Consume any pending state we might have
		if internalData.pendingState ~= nil then
			pendingState = internalData.pendingState
			internalData.pendingState = nil
		end

		-- Consume a standard update to state or props
		if updatedState ~= nil or newProps ~= self.props then
			if pendingState == nil then
				finalState = updatedState or self.state
			else
				finalState = assign(pendingState, updatedState)
			end

			local derivedState = self:__getDerivedState(newProps, finalState)

			if derivedState ~= nil then
				finalState = assign({}, finalState, derivedState)
			end

			updatedState = nil
		else
			finalState = pendingState
		end

		if not self:__resolveUpdate(newProps, finalState) then
			-- If the update was short-circuited, bubble the result up to the caller
			return false
		end

		updateCount = updateCount + 1

		if updateCount > MAX_PENDING_UPDATES then
			error(tooManyUpdatesMessage:format(tostring(internalData.componentClass)), 3)
		end
	until internalData.pendingState == nil

	return true
end

--\[\[
	Internal method used by __update to apply new props and state

	Returns true if the update was completed, false if it was cancelled by shouldUpdate
\]\]
function Component:__resolveUpdate(incomingProps, incomingState)
	if config.internalTypeChecks then
		internalAssert(Type.of(self) == Type.StatefulComponentInstance, "Invalid use of `__resolveUpdate`")
	end

	local internalData = self[InternalData]
	local virtualNode = internalData.virtualNode
	local reconciler = internalData.reconciler

	local oldProps = self.props
	local oldState = self.state

	if incomingProps == nil then
		incomingProps = oldProps
	end
	if incomingState == nil then
		incomingState = oldState
	end

	if self.shouldUpdate ~= nil then
		internalData.lifecyclePhase = ComponentLifecyclePhase.ShouldUpdate
		local continueWithUpdate = self:shouldUpdate(incomingProps, incomingState)

		if not continueWithUpdate then
			internalData.lifecyclePhase = ComponentLifecyclePhase.Idle
			return false
		end
	end

	if self.willUpdate ~= nil then
		internalData.lifecyclePhase = ComponentLifecyclePhase.WillUpdate
		self:willUpdate(incomingProps, incomingState)
	end

	internalData.lifecyclePhase = ComponentLifecyclePhase.Render

	self.props = incomingProps
	self.state = incomingState

	local renderResult = virtualNode.instance:render()

	internalData.lifecyclePhase = ComponentLifecyclePhase.ReconcileChildren
	reconciler.updateVirtualNodeWithRenderResult(virtualNode, virtualNode.hostParent, renderResult)

	if self.didUpdate ~= nil then
		internalData.lifecyclePhase = ComponentLifecyclePhase.DidUpdate
		self:didUpdate(oldProps, oldState)
	end

	internalData.lifecyclePhase = ComponentLifecyclePhase.Idle
	return true
end

return Component ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_763f72be355b1770902b6a0a302baa23"] = _763f72be355b1770902b6a0a302baa23
local _763f72be355b1770902b6a0a302baa23 = nil -- DEALLOCATE PLS :pray:

local _bc24a22c68c00f094ac68169d455a73a = { ClassName = "Folder", Children = {}, Properties = {} }
_bc24a22c68c00f094ac68169d455a73a.Name = "Component.spec"
_4939180de2039ab164a0b6fd3ff1aed2.Children["_bc24a22c68c00f094ac68169d455a73a"] = _bc24a22c68c00f094ac68169d455a73a
local _bc24a22c68c00f094ac68169d455a73a = nil -- DEALLOCATE PLS :pray:
local _aaaf70ba3218db45553503c858bd960a = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_aaaf70ba3218db45553503c858bd960a.Name = "context.spec"
_aaaf70ba3218db45553503c858bd960a.Properties.Source = [[ return function()
	local assertDeepEqual = require(script.Parent.Parent.assertDeepEqual)
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)
	local oneChild = require(script.Parent.Parent.oneChild)

	local Component = require(script.Parent.Parent.Component)

	local noopReconciler = createReconciler(NoopRenderer)

	it("should be provided as an internal api on Component", function()
		local Provider = Component:extend("Provider")

		function Provider:init()
			self:__addContext("foo", "bar")
		end

		function Provider:render() end

		local element = createElement(Provider)
		local hostParent = nil
		local hostKey = "Provider"
		local node = noopReconciler.mountVirtualNode(element, hostParent, hostKey)

		local expectedContext = {
			foo = "bar",
		}

		assertDeepEqual(node.context, expectedContext)
	end)

	it("should be inherited from parent stateful nodes", function()
		local Consumer = Component:extend("Consumer")

		local capturedContext
		function Consumer:init()
			capturedContext = {
				hello = self:__getContext("hello"),
				value = self:__getContext("value"),
			}
		end

		function Consumer:render() end

		local Parent = Component:extend("Parent")

		function Parent:render()
			return createElement(Consumer)
		end

		local element = createElement(Parent)
		local hostParent = nil
		local hostKey = "Parent"
		local context = {
			hello = "world",
			value = 6,
		}
		local node = noopReconciler.mountVirtualNode(element, hostParent, hostKey, context)

		expect(capturedContext).never.to.equal(context)
		expect(capturedContext).never.to.equal(node.context)
		assertDeepEqual(node.context, context)
		assertDeepEqual(capturedContext, context)
	end)

	it("should be inherited from parent function nodes", function()
		local Consumer = Component:extend("Consumer")

		local capturedContext
		function Consumer:init()
			capturedContext = {
				hello = self:__getContext("hello"),
				value = self:__getContext("value"),
			}
		end

		function Consumer:render() end

		local function Parent()
			return createElement(Consumer)
		end

		local element = createElement(Parent)
		local hostParent = nil
		local hostKey = "Parent"
		local context = {
			hello = "world",
			value = 6,
		}
		local node = noopReconciler.mountVirtualNode(element, hostParent, hostKey, context)

		expect(capturedContext).never.to.equal(context)
		expect(capturedContext).never.to.equal(node.context)
		assertDeepEqual(node.context, context)
		assertDeepEqual(capturedContext, context)
	end)

	it("should not copy the context table if it doesn't need to", function()
		local Parent = Component:extend("Parent")

		function Parent:init()
			self:__addContext("parent", "I'm here!")
		end

		function Parent:render()
			-- Create some child element
			return createElement(function() end)
		end

		local element = createElement(Parent)
		local hostParent = nil
		local hostKey = "Parent"
		local parentNode = noopReconciler.mountVirtualNode(element, hostParent, hostKey)

		local expectedContext = {
			parent = "I'm here!",
		}

		assertDeepEqual(parentNode.context, expectedContext)

		local childNode = oneChild(parentNode.children)

		-- Parent and child should have the same context table
		expect(parentNode.context).to.equal(childNode.context)
	end)

	it("should not allow context to move up the tree", function()
		local ChildProvider = Component:extend("ChildProvider")

		function ChildProvider:init()
			self:__addContext("child", "I'm here too!")
		end

		function ChildProvider:render() end

		local ParentProvider = Component:extend("ParentProvider")

		function ParentProvider:init()
			self:__addContext("parent", "I'm here!")
		end

		function ParentProvider:render()
			return createElement(ChildProvider)
		end

		local element = createElement(ParentProvider)
		local hostParent = nil
		local hostKey = "Parent"

		local parentNode = noopReconciler.mountVirtualNode(element, hostParent, hostKey)
		local childNode = oneChild(parentNode.children)

		local expectedParentContext = {
			parent = "I'm here!",
			-- Context does not travel back up
		}

		local expectedChildContext = {
			parent = "I'm here!",
			child = "I'm here too!",
		}

		assertDeepEqual(parentNode.context, expectedParentContext)
		assertDeepEqual(childNode.context, expectedChildContext)
	end)

	it("should contain values put into the tree by parent nodes", function()
		local Consumer = Component:extend("Consumer")

		local capturedContext
		function Consumer:init()
			capturedContext = {
				dont = self:__getContext("dont"),
				frob = self:__getContext("frob"),
			}
		end

		function Consumer:render() end

		local Provider = Component:extend("Provider")

		function Provider:init()
			self:__addContext("frob", "ulator")
		end

		function Provider:render()
			return createElement(Consumer)
		end

		local element = createElement(Provider)
		local hostParent = nil
		local hostKey = "Consumer"
		local context = {
			dont = "try it",
		}
		local node = noopReconciler.mountVirtualNode(element, hostParent, hostKey, context)

		local initialContext = {
			dont = "try it",
		}

		local expectedContext = {
			dont = "try it",
			frob = "ulator",
		}

		-- Because components mutate context, we're careful with equality
		expect(node.context).never.to.equal(context)
		expect(capturedContext).never.to.equal(context)
		expect(capturedContext).never.to.equal(node.context)

		assertDeepEqual(context, initialContext)
		assertDeepEqual(node.context, expectedContext)
		assertDeepEqual(capturedContext, expectedContext)
	end)

	it("should transfer context to children that are replaced", function()
		local ConsumerA = Component:extend("ConsumerA")

		local function captureAllContext(component)
			return {
				A = component:__getContext("A"),
				B = component:__getContext("B"),
				frob = component:__getContext("frob"),
			}
		end

		local capturedContextA
		function ConsumerA:init()
			self:__addContext("A", "hello")

			capturedContextA = captureAllContext(self)
		end

		function ConsumerA:render() end

		local ConsumerB = Component:extend("ConsumerB")

		local capturedContextB
		function ConsumerB:init()
			self:__addContext("B", "hello")

			capturedContextB = captureAllContext(self)
		end

		function ConsumerB:render() end

		local Provider = Component:extend("Provider")

		function Provider:init()
			self:__addContext("frob", "ulator")
		end

		function Provider:render()
			local useConsumerB = self.props.useConsumerB

			if useConsumerB then
				return createElement(ConsumerB)
			else
				return createElement(ConsumerA)
			end
		end

		local hostParent = nil
		local hostKey = "Consumer"

		local element = createElement(Provider)
		local node = noopReconciler.mountVirtualNode(element, hostParent, hostKey)

		local expectedContextA = {
			frob = "ulator",
			A = "hello",
		}

		assertDeepEqual(capturedContextA, expectedContextA)

		local expectedContextB = {
			frob = "ulator",
			B = "hello",
		}

		local replacedElement = createElement(Provider, {
			useConsumerB = true,
		})
		noopReconciler.updateVirtualNode(node, replacedElement)

		assertDeepEqual(capturedContextB, expectedContextB)
	end)
end ]]
_bc24a22c68c00f094ac68169d455a73a.Children["_aaaf70ba3218db45553503c858bd960a"] = _aaaf70ba3218db45553503c858bd960a
local _aaaf70ba3218db45553503c858bd960a = nil -- DEALLOCATE PLS :pray:

local _4c7a944b4df29560c4773fb2fcab070d = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_4c7a944b4df29560c4773fb2fcab070d.Name = "defaultProps.spec"
_4c7a944b4df29560c4773fb2fcab070d.Properties.Source = [[ return function()
	local assertDeepEqual = require(script.Parent.Parent.assertDeepEqual)
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local None = require(script.Parent.Parent.None)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)

	local Component = require(script.Parent.Parent.Component)

	local noopReconciler = createReconciler(NoopRenderer)

	it("should fill in when mounting before init", function()
		local defaultProps = {
			a = 3,
			b = 2,
		}

		local Foo = Component:extend("Foo")

		Foo.defaultProps = defaultProps

		local capturedProps
		function Foo:init()
			capturedProps = self.props
		end

		function Foo:render() end

		local initialProps = {
			b = 4,
			c = 6,
		}

		local element = createElement(Foo, initialProps)
		local hostParent = nil
		local key = "Some Foo"

		noopReconciler.mountVirtualNode(element, hostParent, key)

		local expectedProps = {
			a = defaultProps.a,
			b = initialProps.b,
			c = initialProps.c,
		}

		assertDeepEqual(capturedProps, expectedProps)
	end)

	it("should fill in when updating via props", function()
		local defaultProps = {
			a = 3,
			b = 2,
		}

		local Foo = Component:extend("Foo")

		Foo.defaultProps = defaultProps

		local capturedProps
		function Foo:render()
			capturedProps = self.props
		end

		local initialProps = {
			b = 4,
			c = 6,
		}

		local element = createElement(Foo, initialProps)
		local hostParent = nil
		local key = "Some Foo"

		local node = noopReconciler.mountVirtualNode(element, hostParent, key)

		local updatedProps = {
			c = 5,
		}
		local updatedElement = createElement(Foo, updatedProps)

		noopReconciler.updateVirtualNode(node, updatedElement)

		local expectedProps = {
			a = defaultProps.a,
			b = defaultProps.b,
			c = updatedProps.c,
		}

		assertDeepEqual(capturedProps, expectedProps)
	end)

	it("should respect None to override a default prop with nil", function()
		local defaultProps = {
			a = 3,
			b = 2,
		}

		local Foo = Component:extend("Foo")

		Foo.defaultProps = defaultProps

		local capturedProps
		function Foo:render()
			capturedProps = self.props
		end

		local initialProps = {
			b = None,
			c = 4,
		}

		local element = createElement(Foo, initialProps)
		local hostParent = nil
		local key = "Some Foo"

		noopReconciler.mountVirtualNode(element, hostParent, key)

		local expectedProps = {
			a = defaultProps.a,
			b = nil,
			c = initialProps.c,
		}

		assertDeepEqual(capturedProps, expectedProps)
	end)
end ]]
_bc24a22c68c00f094ac68169d455a73a.Children["_4c7a944b4df29560c4773fb2fcab070d"] = _4c7a944b4df29560c4773fb2fcab070d
local _4c7a944b4df29560c4773fb2fcab070d = nil -- DEALLOCATE PLS :pray:

local _47d1630b71d10bef645be891a2baada2 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_47d1630b71d10bef645be891a2baada2.Name = "didMount.spec"
_47d1630b71d10bef645be891a2baada2.Properties.Source = [[ return function()
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local createSpy = require(script.Parent.Parent.createSpy)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)
	local Type = require(script.Parent.Parent.Type)

	local Component = require(script.Parent.Parent.Component)

	local noopReconciler = createReconciler(NoopRenderer)

	it("should be invoked when mounted", function()
		local MyComponent = Component:extend("MyComponent")

		local didMountSpy = createSpy()

		MyComponent.didMount = didMountSpy.value

		function MyComponent:render()
			return nil
		end

		local element = createElement(MyComponent)
		local hostParent = nil
		local key = "Test"

		noopReconciler.mountVirtualNode(element, hostParent, key)

		expect(didMountSpy.callCount).to.equal(1)

		local values = didMountSpy:captureValues("self")

		expect(Type.of(values.self)).to.equal(Type.StatefulComponentInstance)
	end)
end ]]
_bc24a22c68c00f094ac68169d455a73a.Children["_47d1630b71d10bef645be891a2baada2"] = _47d1630b71d10bef645be891a2baada2
local _47d1630b71d10bef645be891a2baada2 = nil -- DEALLOCATE PLS :pray:

local _744f46cd39adbf1b90852e7479c7121c = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_744f46cd39adbf1b90852e7479c7121c.Name = "didUpdate.spec"
_744f46cd39adbf1b90852e7479c7121c.Properties.Source = [[ return function()
	local assertDeepEqual = require(script.Parent.Parent.assertDeepEqual)
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local createSpy = require(script.Parent.Parent.createSpy)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)
	local Type = require(script.Parent.Parent.Type)

	local Component = require(script.Parent.Parent.Component)

	local noopReconciler = createReconciler(NoopRenderer)

	it("should be invoked when updated via updateVirtualNode", function()
		local MyComponent = Component:extend("MyComponent")

		local didUpdateSpy = createSpy()
		MyComponent.didUpdate = didUpdateSpy.value

		function MyComponent:render()
			return nil
		end

		local initialProps = {
			a = 5,
		}
		local initialElement = createElement(MyComponent, initialProps)
		local hostParent = nil
		local key = "Test"

		local virtualNode = noopReconciler.mountVirtualNode(initialElement, hostParent, key)

		expect(didUpdateSpy.callCount).to.equal(0)

		local newProps = {
			a = 6,
			b = 2,
		}
		local newElement = createElement(MyComponent, newProps)
		noopReconciler.updateVirtualNode(virtualNode, newElement)

		expect(didUpdateSpy.callCount).to.equal(1)

		local values = didUpdateSpy:captureValues("self", "oldProps", "oldState")

		expect(Type.of(values.self)).to.equal(Type.StatefulComponentInstance)
		assertDeepEqual(values.oldProps, initialProps)
		assertDeepEqual(values.oldState, {})
	end)

	it("should be invoked when updated via setState", function()
		local MyComponent = Component:extend("MyComponent")

		local didUpdateSpy = createSpy()
		MyComponent.didUpdate = didUpdateSpy.value

		local initialState = {
			a = 4,
		}

		local setState
		function MyComponent:init()
			setState = function(...)
				return self:setState(...)
			end

			self:setState(initialState)
		end

		function MyComponent:render() end

		local element = createElement(MyComponent)
		local hostParent = nil
		local key = "Test"

		noopReconciler.mountVirtualNode(element, hostParent, key)

		expect(didUpdateSpy.callCount).to.equal(0)

		setState({
			a = 5,
		})

		expect(didUpdateSpy.callCount).to.equal(1)

		local values = didUpdateSpy:captureValues("self", "oldProps", "oldState")

		expect(Type.of(values.self)).to.equal(Type.StatefulComponentInstance)
		assertDeepEqual(values.oldProps, {})
		assertDeepEqual(values.oldState, initialState)
	end)
end ]]
_bc24a22c68c00f094ac68169d455a73a.Children["_744f46cd39adbf1b90852e7479c7121c"] = _744f46cd39adbf1b90852e7479c7121c
local _744f46cd39adbf1b90852e7479c7121c = nil -- DEALLOCATE PLS :pray:

local _cde21da6c2863642f184de79a6f6441f = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_cde21da6c2863642f184de79a6f6441f.Name = "extend.spec"
_cde21da6c2863642f184de79a6f6441f.Properties.Source = [[ return function()
	local Type = require(script.Parent.Parent.Type)

	local Component = require(script.Parent.Parent.Component)

	it("should be extendable", function()
		local MyComponent = Component:extend("The Senate")

		expect(MyComponent).to.be.ok()
		expect(Type.of(MyComponent)).to.equal(Type.StatefulComponentClass)
	end)

	it("should prevent extending a user component", function()
		local MyComponent = Component:extend("Sheev")

		expect(function()
			MyComponent:extend("Frank")
		end).to.throw()
	end)

	it("should use a given name", function()
		local MyComponent = Component:extend("FooBar")

		local name = tostring(MyComponent)

		expect(name).to.be.a("string")
		expect(name:find("FooBar")).to.be.ok()
	end)
end ]]
_bc24a22c68c00f094ac68169d455a73a.Children["_cde21da6c2863642f184de79a6f6441f"] = _cde21da6c2863642f184de79a6f6441f
local _cde21da6c2863642f184de79a6f6441f = nil -- DEALLOCATE PLS :pray:

local _a98c3404ec8e15468cf6c73aa92b0d05 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_a98c3404ec8e15468cf6c73aa92b0d05.Name = "getDerivedStateFromProps.spec"
_a98c3404ec8e15468cf6c73aa92b0d05.Properties.Source = [[ return function()
	local assertDeepEqual = require(script.Parent.Parent.assertDeepEqual)
	local createSpy = require(script.Parent.Parent.createSpy)
	local createElement = require(script.Parent.Parent.createElement)
	local createFragment = require(script.Parent.Parent.createFragment)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)

	local Component = require(script.Parent.Parent.Component)

	local noopReconciler = createReconciler(NoopRenderer)

	it("should be invoked on initial mount", function()
		local getDerivedSpy = createSpy()
		local WithDerivedState = Component:extend("WithDerivedState")

		WithDerivedState.getDerivedStateFromProps = getDerivedSpy.value

		function WithDerivedState:render()
			return nil
		end

		local element = createElement(WithDerivedState, {
			someProp = 1,
		})
		local hostParent = nil
		local hostKey = "WithDerivedState"

		noopReconciler.mountVirtualNode(element, hostParent, hostKey)

		expect(getDerivedSpy.callCount).to.equal(1)

		local values = getDerivedSpy:captureValues("props", "state")

		assertDeepEqual(values.props, { someProp = 1 })
		assertDeepEqual(values.state, {})
	end)

	it("should be invoked when updated via props", function()
		local getDerivedSpy = createSpy()
		local WithDerivedState = Component:extend("WithDerivedState")

		WithDerivedState.getDerivedStateFromProps = getDerivedSpy.value

		function WithDerivedState:render()
			return nil
		end

		local hostParent = nil
		local hostKey = "WithDerivedState"

		local node = noopReconciler.mountVirtualNode(
			createElement(WithDerivedState, {
				someProp = 1,
			}),
			hostParent,
			hostKey
		)

		noopReconciler.updateVirtualNode(
			node,
			createElement(WithDerivedState, {
				someProp = 2,
			})
		)

		expect(getDerivedSpy.callCount).to.equal(2)

		local values = getDerivedSpy:captureValues("props", "state")

		assertDeepEqual(values.props, { someProp = 2 })
		assertDeepEqual(values.state, {})
	end)

	it("should be invoked when updated via state", function()
		local getDerivedSpy = createSpy()
		local WithDerivedState = Component:extend("WithDerivedState")

		WithDerivedState.getDerivedStateFromProps = getDerivedSpy.value

		function WithDerivedState:init()
			self:setState({
				someState = 1,
			})
		end

		function WithDerivedState:render()
			return nil
		end

		local element = createElement(WithDerivedState)
		local hostParent = nil
		local hostKey = "WithDerivedState"

		local node = noopReconciler.mountVirtualNode(element, hostParent, hostKey)

		noopReconciler.updateVirtualNode(node, element, {
			someState = 2,
		})

		-- getDerivedStateFromProps will be called:
		-- * Once on empty props
		-- * Once during the self:setState in init
		-- * Once more, defensively, on the resulting state AFTER init
		-- * On updating with new state via updateVirtualNode
		expect(getDerivedSpy.callCount).to.equal(4)

		local values = getDerivedSpy:captureValues("props", "state")

		assertDeepEqual(values.props, {})
		assertDeepEqual(values.state, { someState = 2 })
	end)

	it("should be invoked when updating via state in init (which skips reconciliation)", function()
		local getDerivedSpy = createSpy()
		local WithDerivedState = Component:extend("WithDerivedState")

		WithDerivedState.getDerivedStateFromProps = getDerivedSpy.value

		function WithDerivedState:init()
			self:setState({
				stateFromInit = 1,
			})
		end

		function WithDerivedState:render()
			return nil
		end

		local element = createElement(WithDerivedState, {
			someProp = 1,
		})
		local hostParent = nil
		local hostKey = "WithDerivedState"

		noopReconciler.mountVirtualNode(element, hostParent, hostKey)

		-- getDerivedStateFromProps will be called:
		-- * Once on empty props
		-- * Once during the self:setState in init
		-- * Once more, defensively, on the resulting state AFTER init
		expect(getDerivedSpy.callCount).to.equal(3)

		local values = getDerivedSpy:captureValues("props", "state")

		assertDeepEqual(values.props, {
			someProp = 1,
		})
		assertDeepEqual(values.state, {
			stateFromInit = 1,
		})
	end)

	it("should receive defaultProps", function()
		local getDerivedSpy = createSpy()
		local WithDerivedState = Component:extend("WithDerivedState")

		WithDerivedState.defaultProps = {
			someDefaultProp = "foo",
		}

		WithDerivedState.getDerivedStateFromProps = getDerivedSpy.value

		function WithDerivedState:render()
			return nil
		end

		local element = createElement(WithDerivedState, {
			someProp = 1,
		})
		local hostParent = nil
		local hostKey = "WithDerivedState"

		local node = noopReconciler.mountVirtualNode(element, hostParent, hostKey)

		expect(getDerivedSpy.callCount).to.equal(1)

		local values = getDerivedSpy:captureValues("props", "state")

		assertDeepEqual(values.props, {
			someDefaultProp = "foo",
			someProp = 1,
		})

		-- Update via props, confirm that defaultProp is still present
		element = createElement(WithDerivedState, {
			someProp = 2,
		})

		noopReconciler.updateVirtualNode(node, element)

		expect(getDerivedSpy.callCount).to.equal(2)

		values = getDerivedSpy:captureValues("props", "state")

		assertDeepEqual(values.props, {
			someDefaultProp = "foo",
			someProp = 2,
		})
	end)

	it("should derive state for all setState updates, even when deferred", function()
		local Child = Component:extend("Child")
		local stateUpdaterSpy = createSpy(function()
			return {}
		end)
		local stateDerivedSpy = createSpy()

		function Child:render()
			return nil
		end

		function Child:didMount()
			self.props.callback()
		end

		local Parent = Component:extend("Parent")

		Parent.getDerivedStateFromProps = stateDerivedSpy.value

		function Parent:render()
			local callback = function()
				self:setState(stateUpdaterSpy.value)
			end

			return createFragment({
				ChildA = createElement(Child, {
					callback = callback,
				}),
				ChildB = createElement(Child, {
					callback = callback,
				}),
			})
		end

		local element = createElement(Parent)
		local hostParent = nil
		local key = "Test"

		noopReconciler.mountVirtualNode(element, hostParent, key)

		expect(stateUpdaterSpy.callCount).to.equal(2)

		-- getDerivedStateFromProps is always called on initial state
		expect(stateDerivedSpy.callCount).to.equal(3)
	end)

	it("should have derived state after assigning to state in init", function()
		local getStateCallback
		local getDerivedSpy = createSpy(function()
			return {
				derived = true,
			}
		end)
		local WithDerivedState = Component:extend("WithDerivedState")

		WithDerivedState.getDerivedStateFromProps = getDerivedSpy.value

		function WithDerivedState:init()
			self.state = {
				init = true,
			}

			getStateCallback = function()
				return self.state
			end
		end

		function WithDerivedState:render()
			return nil
		end

		local hostParent = nil
		local hostKey = "WithDerivedState"
		local element = createElement(WithDerivedState)

		noopReconciler.mountVirtualNode(element, hostParent, hostKey)

		expect(getDerivedSpy.callCount).to.equal(2)

		assertDeepEqual(getStateCallback(), {
			init = true,
			derived = true,
		})
	end)
end ]]
_bc24a22c68c00f094ac68169d455a73a.Children["_a98c3404ec8e15468cf6c73aa92b0d05"] = _a98c3404ec8e15468cf6c73aa92b0d05
local _a98c3404ec8e15468cf6c73aa92b0d05 = nil -- DEALLOCATE PLS :pray:

local _c87094dc786ff25f09b247e22aafa04d = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_c87094dc786ff25f09b247e22aafa04d.Name = "getElementTraceback.spec"
_c87094dc786ff25f09b247e22aafa04d.Properties.Source = [[ return function()
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local GlobalConfig = require(script.Parent.Parent.GlobalConfig)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)

	local Component = require(script.Parent.Parent.Component)

	local noopReconciler = createReconciler(NoopRenderer)

	it("should return stack traces in initial renders", function()
		local TestComponent = Component:extend("TestComponent")

		local stackTrace
		function TestComponent:init()
			stackTrace = self:getElementTraceback()
		end

		function TestComponent:render()
			return nil
		end

		local config = {
			elementTracing = true,
		}

		GlobalConfig.scoped(config, function()
			local element = createElement(TestComponent)
			local hostParent = nil
			local key = "Some key"

			noopReconciler.mountVirtualNode(element, hostParent, key)
		end)

		expect(stackTrace).to.be.a("string")
	end)

	itSKIP("it should return an updated stack trace after an update", function() end)

	it("should return nil when elementTracing is off", function()
		local stackTrace = nil

		local config = {
			elementTracing = false,
		}

		local TestComponent = Component:extend("TestComponent")

		function TestComponent:init()
			stackTrace = self:getElementTraceback()
		end

		function TestComponent:render()
			return nil
		end

		GlobalConfig.scoped(config, function()
			local element = createElement(TestComponent)
			local hostParent = nil
			local key = "Some key"

			noopReconciler.mountVirtualNode(element, hostParent, key)
		end)

		expect(stackTrace).to.equal(nil)
	end)
end ]]
_bc24a22c68c00f094ac68169d455a73a.Children["_c87094dc786ff25f09b247e22aafa04d"] = _c87094dc786ff25f09b247e22aafa04d
local _c87094dc786ff25f09b247e22aafa04d = nil -- DEALLOCATE PLS :pray:

local _984129ecb018ec85afe98e5376248cd5 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_984129ecb018ec85afe98e5376248cd5.Name = "init.spec"
_984129ecb018ec85afe98e5376248cd5.Properties.Source = [[ return function()
	local assertDeepEqual = require(script.Parent.Parent.assertDeepEqual)
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local createSpy = require(script.Parent.Parent.createSpy)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)
	local Type = require(script.Parent.Parent.Type)

	local Component = require(script.Parent.Parent.Component)

	local noopReconciler = createReconciler(NoopRenderer)

	it("should be invoked with props when mounted", function()
		local MyComponent = Component:extend("MyComponent")

		local initSpy = createSpy()

		MyComponent.init = initSpy.value

		function MyComponent:render()
			return nil
		end

		local props = {
			a = 5,
		}
		local element = createElement(MyComponent, props)
		local hostParent = nil
		local key = "Some Component Key"

		noopReconciler.mountVirtualNode(element, hostParent, key)

		expect(initSpy.callCount).to.equal(1)

		local values = initSpy:captureValues("self", "props")

		expect(Type.of(values.self)).to.equal(Type.StatefulComponentInstance)
		expect(typeof(values.props)).to.equal("table")
		assertDeepEqual(values.props, props)
	end)
end ]]
_bc24a22c68c00f094ac68169d455a73a.Children["_984129ecb018ec85afe98e5376248cd5"] = _984129ecb018ec85afe98e5376248cd5
local _984129ecb018ec85afe98e5376248cd5 = nil -- DEALLOCATE PLS :pray:

local _c49b18efb8acb09c0da8c68ca9861e25 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_c49b18efb8acb09c0da8c68ca9861e25.Name = "legacyContext.spec"
_c49b18efb8acb09c0da8c68ca9861e25.Properties.Source = [[ return function()
	local assertDeepEqual = require(script.Parent.Parent.assertDeepEqual)
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)

	local Component = require(script.Parent.Parent.Component)

	local noopReconciler = createReconciler(NoopRenderer)

	it("should be provided as a mutable self._context in Component:init", function()
		local Provider = Component:extend("Provider")

		function Provider:init()
			self._context.foo = "bar"
		end

		function Provider:render() end

		local element = createElement(Provider)
		local hostParent = nil
		local hostKey = "Provider"
		local node = noopReconciler.mountVirtualNode(element, hostParent, hostKey)

		local expectedContext = {
			foo = "bar",
		}

		assertDeepEqual(node.legacyContext, expectedContext)
	end)

	it("should be inherited from parent stateful nodes", function()
		local Consumer = Component:extend("Consumer")

		local capturedContext
		function Consumer:init()
			capturedContext = self._context
		end

		function Consumer:render() end

		local Parent = Component:extend("Parent")

		function Parent:render()
			return createElement(Consumer)
		end

		local element = createElement(Parent)
		local hostParent = nil
		local hostKey = "Parent"
		local context = {
			hello = "world",
			value = 6,
		}
		local node = noopReconciler.mountVirtualNode(element, hostParent, hostKey, nil, context)

		expect(capturedContext).never.to.equal(context)
		expect(capturedContext).never.to.equal(node.legacyContext)
		assertDeepEqual(node.legacyContext, context)
		assertDeepEqual(capturedContext, context)
	end)

	it("should be inherited from parent function nodes", function()
		local Consumer = Component:extend("Consumer")

		local capturedContext
		function Consumer:init()
			capturedContext = self._context
		end

		function Consumer:render() end

		local function Parent()
			return createElement(Consumer)
		end

		local element = createElement(Parent)
		local hostParent = nil
		local hostKey = "Parent"
		local context = {
			hello = "world",
			value = 6,
		}
		local node = noopReconciler.mountVirtualNode(element, hostParent, hostKey, nil, context)

		expect(capturedContext).never.to.equal(context)
		expect(capturedContext).never.to.equal(node.legacyContext)
		assertDeepEqual(node.legacyContext, context)
		assertDeepEqual(capturedContext, context)
	end)

	it("should contain values put into the tree by parent nodes", function()
		local Consumer = Component:extend("Consumer")

		local capturedContext
		function Consumer:init()
			capturedContext = self._context
		end

		function Consumer:render() end

		local Provider = Component:extend("Provider")

		function Provider:init()
			self._context.frob = "ulator"
		end

		function Provider:render()
			return createElement(Consumer)
		end

		local element = createElement(Provider)
		local hostParent = nil
		local hostKey = "Consumer"
		local context = {
			dont = "try it",
		}
		local node = noopReconciler.mountVirtualNode(element, hostParent, hostKey, nil, context)

		local initialContext = {
			dont = "try it",
		}

		local expectedContext = {
			dont = "try it",
			frob = "ulator",
		}

		-- Because components mutate context, we're careful with equality
		expect(node.legacyContext).never.to.equal(context)
		expect(capturedContext).never.to.equal(context)
		expect(capturedContext).never.to.equal(node.legacyContext)

		assertDeepEqual(context, initialContext)
		assertDeepEqual(node.legacyContext, expectedContext)
		assertDeepEqual(capturedContext, expectedContext)
	end)

	it("should transfer context to children that are replaced", function()
		local ConsumerA = Component:extend("ConsumerA")

		local capturedContextA
		function ConsumerA:init()
			self._context.A = "hello"

			capturedContextA = self._context
		end

		function ConsumerA:render() end

		local ConsumerB = Component:extend("ConsumerB")

		local capturedContextB
		function ConsumerB:init()
			self._context.B = "hello"

			capturedContextB = self._context
		end

		function ConsumerB:render() end

		local Provider = Component:extend("Provider")

		function Provider:init()
			self._context.frob = "ulator"
		end

		function Provider:render()
			local useConsumerB = self.props.useConsumerB

			if useConsumerB then
				return createElement(ConsumerB)
			else
				return createElement(ConsumerA)
			end
		end

		local hostParent = nil
		local hostKey = "Consumer"

		local element = createElement(Provider)
		local node = noopReconciler.mountVirtualNode(element, hostParent, hostKey)

		local expectedContextA = {
			frob = "ulator",
			A = "hello",
		}

		assertDeepEqual(capturedContextA, expectedContextA)

		local expectedContextB = {
			frob = "ulator",
			B = "hello",
		}

		local replacedElement = createElement(Provider, {
			useConsumerB = true,
		})
		noopReconciler.updateVirtualNode(node, replacedElement)

		assertDeepEqual(capturedContextB, expectedContextB)
	end)
end ]]
_bc24a22c68c00f094ac68169d455a73a.Children["_c49b18efb8acb09c0da8c68ca9861e25"] = _c49b18efb8acb09c0da8c68ca9861e25
local _c49b18efb8acb09c0da8c68ca9861e25 = nil -- DEALLOCATE PLS :pray:

local _b93f8365bd4335fc980521343dea9991 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_b93f8365bd4335fc980521343dea9991.Name = "render.spec"
_b93f8365bd4335fc980521343dea9991.Properties.Source = [[ return function()
	local assertDeepEqual = require(script.Parent.Parent.assertDeepEqual)
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local createSpy = require(script.Parent.Parent.createSpy)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)
	local Type = require(script.Parent.Parent.Type)

	local Component = require(script.Parent.Parent.Component)

	local noopReconciler = createReconciler(NoopRenderer)

	it("should throw on mount if not overridden", function()
		local MyComponent = Component:extend("MyComponent")

		local element = createElement(MyComponent)
		local hostParent = nil
		local key = "Test"

		local success, result = pcall(function()
			noopReconciler.mountVirtualNode(element, hostParent, key)
		end)

		expect(success).to.equal(false)
		expect(result:match("MyComponent")).to.be.ok()
		expect(result:match("render")).to.be.ok()
	end)

	it("should be invoked when a component is mounted", function()
		local Foo = Component:extend("Foo")

		local capturedProps
		local capturedState
		local renderSpy = createSpy(function(self)
			capturedProps = self.props
			capturedState = self.state
		end)
		Foo.render = renderSpy.value

		local element = createElement(Foo)
		local hostParent = nil
		local key = "Foo Test"

		noopReconciler.mountVirtualNode(element, hostParent, key)

		expect(renderSpy.callCount).to.equal(1)

		local renderArguments = renderSpy:captureValues("self")

		expect(Type.of(renderArguments.self)).to.equal(Type.StatefulComponentInstance)
		assertDeepEqual(capturedProps, {})
		assertDeepEqual(capturedState, {})
	end)

	it("should be invoked when a component is updated via props", function()
		local Foo = Component:extend("Foo")

		local capturedProps
		local capturedState
		local renderSpy = createSpy(function(self)
			capturedProps = self.props
			capturedState = self.state
		end)
		Foo.render = renderSpy.value

		local initialProps = {
			a = 2,
		}
		local element = createElement(Foo, initialProps)
		local hostParent = nil
		local key = "Foo Test"

		local node = noopReconciler.mountVirtualNode(element, hostParent, key)

		expect(renderSpy.callCount).to.equal(1)

		local firstRenderArguments = renderSpy:captureValues("self")
		local firstProps = capturedProps
		local firstState = capturedState

		expect(Type.of(firstRenderArguments.self)).to.equal(Type.StatefulComponentInstance)
		assertDeepEqual(firstProps, initialProps)
		assertDeepEqual(firstState, {})

		local updatedProps = {
			a = 3,
		}
		local newElement = createElement(Foo, updatedProps)

		noopReconciler.updateVirtualNode(node, newElement)

		expect(renderSpy.callCount).to.equal(2)

		local secondRenderArguments = renderSpy:captureValues("self")
		local secondProps = capturedProps
		local secondState = capturedState

		expect(Type.of(secondRenderArguments.self)).to.equal(Type.StatefulComponentInstance)
		expect(secondProps).never.to.equal(firstProps)
		assertDeepEqual(secondProps, updatedProps)
		expect(secondState).to.equal(firstState)
	end)

	it("should be invoked when a component is updated via state", function()
		local Foo = Component:extend("Foo")

		local setState
		function Foo:init()
			setState = function(...)
				return self:setState(...)
			end
		end

		local capturedProps
		local capturedState
		local renderSpy = createSpy(function(self)
			capturedProps = self.props
			capturedState = self.state
		end)
		Foo.render = renderSpy.value

		local element = createElement(Foo)
		local hostParent = nil
		local key = "Foo Test"

		noopReconciler.mountVirtualNode(element, hostParent, key)

		expect(renderSpy.callCount).to.equal(1)

		local firstRenderArguments = renderSpy:captureValues("self")
		local firstProps = capturedProps
		local firstState = capturedState

		expect(Type.of(firstRenderArguments.self)).to.equal(Type.StatefulComponentInstance)

		setState({})

		expect(renderSpy.callCount).to.equal(2)

		local renderArguments = renderSpy:captureValues("self")

		expect(Type.of(renderArguments.self)).to.equal(Type.StatefulComponentInstance)
		expect(capturedProps).to.equal(firstProps)
		expect(capturedState).never.to.equal(firstState)
	end)

	itSKIP("Test defaultProps on initial render", function() end)
	itSKIP("Test defaultProps on prop update", function() end)
	itSKIP("Test defaultProps on state update", function() end)
end ]]
_bc24a22c68c00f094ac68169d455a73a.Children["_b93f8365bd4335fc980521343dea9991"] = _b93f8365bd4335fc980521343dea9991
local _b93f8365bd4335fc980521343dea9991 = nil -- DEALLOCATE PLS :pray:

local _9bb1dd5b26cef5800e12a9b6e44bf01f = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_9bb1dd5b26cef5800e12a9b6e44bf01f.Name = "setState.spec"
_9bb1dd5b26cef5800e12a9b6e44bf01f.Properties.Source = [[ return function()
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local createSpy = require(script.Parent.Parent.createSpy)
	local None = require(script.Parent.Parent.None)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)

	local Component = require(script.Parent.Parent.Component)

	local noopReconciler = createReconciler(NoopRenderer)

	describe("setState", function()
		it("should not trigger an extra update when called in init", function()
			local renderCount = 0
			local updateCount = 0
			local capturedState

			local InitComponent = Component:extend("InitComponent")

			function InitComponent:init()
				self:setState({
					a = 1,
				})
			end

			function InitComponent:willUpdate()
				updateCount = updateCount + 1
			end

			function InitComponent:render()
				renderCount = renderCount + 1
				capturedState = self.state
				return nil
			end

			local initElement = createElement(InitComponent)

			noopReconciler.mountVirtualTree(initElement)

			expect(renderCount).to.equal(1)
			expect(updateCount).to.equal(0)
			expect(capturedState.a).to.equal(1)
		end)

		it("should throw when called in render", function()
			local TestComponent = Component:extend("TestComponent")

			function TestComponent:render()
				self:setState({
					a = 1,
				})
			end

			local renderElement = createElement(TestComponent)

			local success, result = pcall(noopReconciler.mountVirtualTree, renderElement)

			expect(success).to.equal(false)
			expect(result:match("render")).to.be.ok()
			expect(result:match("TestComponent")).to.be.ok()
		end)

		it("should throw when called in shouldUpdate", function()
			local TestComponent = Component:extend("TestComponent")

			function TestComponent:render()
				return nil
			end

			function TestComponent:shouldUpdate()
				self:setState({
					a = 1,
				})
			end

			local initialElement = createElement(TestComponent)
			local updatedElement = createElement(TestComponent)

			local tree = noopReconciler.mountVirtualTree(initialElement)

			local success, result = pcall(noopReconciler.updateVirtualTree, tree, updatedElement)

			expect(success).to.equal(false)
			expect(result:match("shouldUpdate")).to.be.ok()
			expect(result:match("TestComponent")).to.be.ok()
		end)

		it("should throw when called in willUpdate", function()
			local TestComponent = Component:extend("TestComponent")

			function TestComponent:render()
				return nil
			end

			function TestComponent:willUpdate()
				self:setState({
					a = 1,
				})
			end

			local initialElement = createElement(TestComponent)
			local updatedElement = createElement(TestComponent)
			local tree = noopReconciler.mountVirtualTree(initialElement)

			local success, result = pcall(noopReconciler.updateVirtualTree, tree, updatedElement)

			expect(success).to.equal(false)
			expect(result:match("willUpdate")).to.be.ok()
			expect(result:match("TestComponent")).to.be.ok()
		end)

		it("should not throw when called in willUnmount", function()
			local TestComponent = Component:extend("TestComponent")

			function TestComponent:render()
				return nil
			end

			function TestComponent:willUnmount()
				self:setState({
					a = 1,
				})
			end

			local element = createElement(TestComponent)
			local tree = noopReconciler.mountVirtualTree(element)

			local success, _ = pcall(noopReconciler.unmountVirtualTree, tree)

			expect(success).to.equal(true)
		end)

		it("should remove values from state when the value is None", function()
			local TestComponent = Component:extend("TestComponent")
			local setStateCallback, getStateCallback

			function TestComponent:init()
				setStateCallback = function(newState)
					self:setState(newState)
				end

				getStateCallback = function()
					return self.state
				end

				self:setState({
					value = 0,
				})
			end

			function TestComponent:render()
				return nil
			end

			local element = createElement(TestComponent)
			local instance = noopReconciler.mountVirtualNode(element, nil, "Test")

			expect(getStateCallback().value).to.equal(0)

			setStateCallback({
				value = None,
			})

			expect(getStateCallback().value).to.equal(nil)

			noopReconciler.unmountVirtualNode(instance)
		end)

		it("should invoke functions to compute a partial state", function()
			local TestComponent = Component:extend("TestComponent")
			local setStateCallback, getStateCallback, getPropsCallback

			function TestComponent:init()
				setStateCallback = function(newState)
					self:setState(newState)
				end

				getStateCallback = function()
					return self.state
				end

				getPropsCallback = function()
					return self.props
				end

				self:setState({
					value = 0,
				})
			end

			function TestComponent:render()
				return nil
			end

			local element = createElement(TestComponent)
			local instance = noopReconciler.mountVirtualNode(element, nil, "Test")

			expect(getStateCallback().value).to.equal(0)

			setStateCallback(function(state, props)
				expect(state).to.equal(getStateCallback())
				expect(props).to.equal(getPropsCallback())

				return {
					value = state.value + 1,
				}
			end)

			expect(getStateCallback().value).to.equal(1)

			noopReconciler.unmountVirtualNode(instance)
		end)

		it("should cancel rendering if the function returns nil", function()
			local TestComponent = Component:extend("TestComponent")
			local setStateCallback
			local renderCount = 0

			function TestComponent:init()
				setStateCallback = function(newState)
					self:setState(newState)
				end

				self:setState({
					value = 0,
				})
			end

			function TestComponent:render()
				renderCount = renderCount + 1
				return nil
			end

			local element = createElement(TestComponent)
			local instance = noopReconciler.mountVirtualNode(element, nil, "Test")
			expect(renderCount).to.equal(1)

			setStateCallback(function(_state, _props)
				return nil
			end)

			expect(renderCount).to.equal(1)

			noopReconciler.unmountVirtualNode(instance)
		end)
	end)

	describe("setState suspension", function()
		it("should defer setState triggered while reconciling", function()
			local Child = Component:extend("Child")
			local getParentStateCallback

			function Child:render()
				return nil
			end

			function Child:didMount()
				self.props.callback()
			end

			local Parent = Component:extend("Parent")

			function Parent:init()
				getParentStateCallback = function()
					return self.state
				end
			end

			function Parent:render()
				return createElement(Child, {
					callback = function()
						self:setState({
							foo = "bar",
						})
					end,
				})
			end

			local element = createElement(Parent)
			local hostParent = nil
			local key = "Test"

			local result = noopReconciler.mountVirtualNode(element, hostParent, key)

			expect(result).to.be.ok()
			expect(getParentStateCallback().foo).to.equal("bar")
		end)

		it("should defer setState triggered while reconciling during an update", function()
			local Child = Component:extend("Child")
			local getParentStateCallback

			function Child:render()
				return nil
			end

			function Child:didUpdate()
				self.props.callback()
			end

			local Parent = Component:extend("Parent")

			function Parent:init()
				getParentStateCallback = function()
					return self.state
				end
			end

			function Parent:render()
				return createElement(Child, {
					callback = function()
						-- This guards against a stack overflow that would be OUR fault
						if not self.state.foo then
							self:setState({
								foo = "bar",
							})
						end
					end,
				})
			end

			local element = createElement(Parent)
			local hostParent = nil
			local key = "Test"

			local result = noopReconciler.mountVirtualNode(element, hostParent, key)

			expect(result).to.be.ok()
			expect(getParentStateCallback().foo).to.equal(nil)

			result = noopReconciler.updateVirtualNode(result, createElement(Parent))

			expect(result).to.be.ok()
			expect(getParentStateCallback().foo).to.equal("bar")

			noopReconciler.unmountVirtualNode(result)
		end)

		it("should combine pending state changes properly", function()
			local Child = Component:extend("Child")
			local getParentStateCallback

			function Child:render()
				return nil
			end

			function Child:didMount()
				self.props.callback("foo", 1)
				self.props.callback("bar", 3)
			end

			local Parent = Component:extend("Parent")

			function Parent:init()
				getParentStateCallback = function()
					return self.state
				end
			end

			function Parent:render()
				return createElement(Child, {
					callback = function(key, value)
						self:setState({
							[key] = value,
						})
					end,
				})
			end

			local element = createElement(Parent)
			local hostParent = nil
			local key = "Test"

			local result = noopReconciler.mountVirtualNode(element, hostParent, key)

			expect(result).to.be.ok()
			expect(getParentStateCallback().foo).to.equal(1)
			expect(getParentStateCallback().bar).to.equal(3)

			noopReconciler.unmountVirtualNode(result)
		end)

		it("should abort properly when functional setState returns nil while deferred", function()
			local Child = Component:extend("Child")

			function Child:render()
				return nil
			end

			function Child:didMount()
				self.props.callback()
			end

			local Parent = Component:extend("Parent")

			local renderSpy = createSpy(function(self)
				return createElement(Child, {
					callback = function()
						self:setState(function()
							-- abort the setState
							return nil
						end)
					end,
				})
			end)

			Parent.render = renderSpy.value

			local element = createElement(Parent)
			local hostParent = nil
			local key = "Test"

			local result = noopReconciler.mountVirtualNode(element, hostParent, key)

			expect(result).to.be.ok()
			expect(renderSpy.callCount).to.equal(1)

			noopReconciler.unmountVirtualNode(result)
		end)

		it("should still apply pending state if a subsequent state update was aborted", function()
			local Child = Component:extend("Child")
			local getParentStateCallback

			function Child:render()
				return nil
			end

			function Child:didMount()
				self.props.callback(function()
					return {
						foo = 1,
					}
				end)
				self.props.callback(function()
					return nil
				end)
			end

			local Parent = Component:extend("Parent")

			function Parent:init()
				getParentStateCallback = function()
					return self.state
				end
			end

			function Parent:render()
				return createElement(Child, {
					callback = function(stateUpdater)
						self:setState(stateUpdater)
					end,
				})
			end

			local element = createElement(Parent)
			local hostParent = nil
			local key = "Test"

			local result = noopReconciler.mountVirtualNode(element, hostParent, key)

			expect(result).to.be.ok()
			expect(getParentStateCallback().foo).to.equal(1)

			noopReconciler.unmountVirtualNode(result)
		end)

		it("should not re-process new state when pending state is present after update", function()
			local setComponentState
			local getComponentState

			local MyComponent = Component:extend("MyComponent")

			function MyComponent:init()
				self:setState({
					hasUpdatedOnce = false,
					counter = 0,
				})

				setComponentState = function(mapState)
					self:setState(mapState)
				end

				getComponentState = function()
					return self.state
				end
			end

			function MyComponent:render()
				return nil
			end

			function MyComponent:didUpdate()
				if self.state.hasUpdatedOnce == false then
					self:setState({
						hasUpdatedOnce = true,
					})
				end
			end

			local element = createElement(MyComponent)
			local hostParent = nil
			local key = "Test"

			noopReconciler.mountVirtualNode(element, hostParent, key)

			expect(getComponentState().hasUpdatedOnce).to.equal(false)
			expect(getComponentState().counter).to.equal(0)

			setComponentState(function(state)
				return {
					counter = state.counter + 1,
				}
			end)

			expect(getComponentState().hasUpdatedOnce).to.equal(true)
			expect(getComponentState().counter).to.equal(1)
		end)

		it("should throw when an infinite update is triggered", function()
			local InfiniteUpdater = Component:extend("InfiniteUpdater")

			function InfiniteUpdater:render()
				return nil
			end

			function InfiniteUpdater:didMount()
				self:setState({})
			end

			function InfiniteUpdater:didUpdate()
				self:setState({})
			end

			local element = createElement(InfiniteUpdater)
			local hostParent = nil
			local key = "Test"

			local success, result = pcall(noopReconciler.mountVirtualNode, element, hostParent, key)

			expect(success).to.equal(false)
			expect(result:find("InfiniteUpdater")).to.be.ok()
			expect(result:find("reached the setState update recursion limit")).to.be.ok()
		end)

		itSKIP("should process single updates with both new and pending state", function()
			--\[\[
				This situation shouldn't be possible currently, but the implementation
				should support it for future update de-duplication
			\]\]
		end)

		it("should call trigger update after didMount when setting state in didMount", function()
			--\[\[
				Before setState suspension, it was possible to call setState in didMount but it would
				not actually finish resolving didMount until after the entire update.

				This is theoretically problematic, as it means that lifecycle methods like didUpdate
				could be called before didMount is finished. setState suspension resolves this by
				suspending state updates made in didMount and didUpdate as well as reconciliation
			\]\]
			local MyComponent = Component:extend("MyComponent")

			function MyComponent:init()
				self:setState({
					status = "initial mount",
				})

				self.isMounted = false
			end

			function MyComponent:render()
				return nil
			end

			function MyComponent:didMount()
				self:setState({
					status = "mounted",
				})

				self.isMounted = true
			end

			function MyComponent:didUpdate(_oldProps, oldState)
				expect(oldState.status).to.equal("initial mount")
				expect(self.state.status).to.equal("mounted")

				expect(self.isMounted).to.equal(true)
			end

			local element = createElement(MyComponent)
			local hostParent = nil
			local key = "Test"

			local result = noopReconciler.mountVirtualNode(element, hostParent, key)

			expect(result).to.be.ok()
		end)
	end)
end ]]
_bc24a22c68c00f094ac68169d455a73a.Children["_9bb1dd5b26cef5800e12a9b6e44bf01f"] = _9bb1dd5b26cef5800e12a9b6e44bf01f
local _9bb1dd5b26cef5800e12a9b6e44bf01f = nil -- DEALLOCATE PLS :pray:

local _0008f113c8712a2030ce6130b05f6bd3 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_0008f113c8712a2030ce6130b05f6bd3.Name = "shouldUpdate.spec"
_0008f113c8712a2030ce6130b05f6bd3.Properties.Source = [[ return function()
	local assertDeepEqual = require(script.Parent.Parent.assertDeepEqual)
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local createSpy = require(script.Parent.Parent.createSpy)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)
	local Type = require(script.Parent.Parent.Type)

	local Component = require(script.Parent.Parent.Component)

	local noopReconciler = createReconciler(NoopRenderer)

	it("should be invoked when props update", function()
		local MyComponent = Component:extend("MyComponent")

		local capturedProps
		local capturedState
		local shouldUpdateSpy = createSpy(function(self)
			capturedProps = self.props
			capturedState = self.state

			return true
		end)

		MyComponent.shouldUpdate = shouldUpdateSpy.value

		function MyComponent:render()
			return nil
		end

		local initialProps = {
			a = 5,
		}
		local initialElement = createElement(MyComponent, initialProps)
		local hostParent = nil
		local key = "Test"

		local node = noopReconciler.mountVirtualNode(initialElement, hostParent, key)

		expect(shouldUpdateSpy.callCount).to.equal(0)

		local newProps = {
			a = 6,
			b = 2,
		}
		local newElement = createElement(MyComponent, newProps)
		noopReconciler.updateVirtualNode(node, newElement)

		expect(shouldUpdateSpy.callCount).to.equal(1)

		local values = shouldUpdateSpy:captureValues("self", "newProps", "newState")

		expect(Type.of(values.self)).to.equal(Type.StatefulComponentInstance)

		assertDeepEqual(values.newProps, newProps)

		assertDeepEqual(capturedProps, initialProps)

		expect(values.newState).to.equal(capturedState)
		assertDeepEqual(capturedState, {})
	end)

	it("should be invoked when state is updated", function()
		local MyComponent = Component:extend("MyComponent")

		local initialState = {
			a = 1,
		}

		local setState
		local initState
		function MyComponent:init()
			setState = function(...)
				return self:setState(...)
			end

			self:setState(initialState)

			initState = self.state
		end

		local capturedProps
		local capturedState
		local shouldUpdateSpy = createSpy(function(self)
			capturedProps = self.props
			capturedState = self.state

			return true
		end)

		MyComponent.shouldUpdate = shouldUpdateSpy.value

		function MyComponent:render()
			return nil
		end

		local initialElement = createElement(MyComponent)
		local hostParent = nil
		local key = "Test"

		noopReconciler.mountVirtualNode(initialElement, hostParent, key)

		expect(shouldUpdateSpy.callCount).to.equal(0)

		local newState = {
			a = 2,
			b = 3,
		}

		setState(newState)

		expect(shouldUpdateSpy.callCount).to.equal(1)

		local values = shouldUpdateSpy:captureValues("self", "newProps", "newState")

		expect(Type.of(values.self)).to.equal(Type.StatefulComponentInstance)

		expect(values.newProps).to.equal(capturedProps)
		assertDeepEqual(capturedProps, {})

		assertDeepEqual(capturedState, initialState)
		expect(capturedState).to.equal(initState)
		assertDeepEqual(values.newState, newState)
	end)

	it("should not abort an update when returning true", function()
		local MyComponent = Component:extend("MyComponent")

		function MyComponent:shouldUpdate()
			return true
		end

		local renderSpy = createSpy()

		MyComponent.render = renderSpy.value

		local initialElement = createElement(MyComponent)
		local hostParent = nil
		local key = "Test"

		local node = noopReconciler.mountVirtualNode(initialElement, hostParent, key)

		expect(renderSpy.callCount).to.equal(1)

		local newElement = createElement(MyComponent)
		noopReconciler.updateVirtualNode(node, newElement)

		expect(renderSpy.callCount).to.equal(2)
	end)

	it("should abort an update when retuning false", function()
		local MyComponent = Component:extend("MyComponent")

		function MyComponent:shouldUpdate()
			return false
		end

		local renderSpy = createSpy()

		MyComponent.render = renderSpy.value

		local initialElement = createElement(MyComponent)
		local hostParent = nil
		local key = "Test"

		local node = noopReconciler.mountVirtualNode(initialElement, hostParent, key)

		expect(renderSpy.callCount).to.equal(1)

		local newElement = createElement(MyComponent)
		noopReconciler.updateVirtualNode(node, newElement)

		expect(renderSpy.callCount).to.equal(1)
	end)
end ]]
_bc24a22c68c00f094ac68169d455a73a.Children["_0008f113c8712a2030ce6130b05f6bd3"] = _0008f113c8712a2030ce6130b05f6bd3
local _0008f113c8712a2030ce6130b05f6bd3 = nil -- DEALLOCATE PLS :pray:

local _a53894be1db05cc20eda1aa9f3d205ac = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_a53894be1db05cc20eda1aa9f3d205ac.Name = "validateProps.spec"
_a53894be1db05cc20eda1aa9f3d205ac.Properties.Source = [[ return function()
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local createSpy = require(script.Parent.Parent.createSpy)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)
	local GlobalConfig = require(script.Parent.Parent.GlobalConfig)

	local Component = require(script.Parent.Parent.Component)

	local noopReconciler = createReconciler(NoopRenderer)

	it("should be invoked when mounted", function()
		local config = {
			propValidation = true,
		}

		GlobalConfig.scoped(config, function()
			local MyComponent = Component:extend("MyComponent")

			local validatePropsSpy = createSpy(function()
				return true
			end)

			MyComponent.validateProps = validatePropsSpy.value

			function MyComponent:render()
				return nil
			end

			local element = createElement(MyComponent)
			local hostParent = nil
			local key = "Test"

			noopReconciler.mountVirtualNode(element, hostParent, key)
			expect(validatePropsSpy.callCount).to.equal(1)
		end)
	end)

	it("should be invoked when props change", function()
		local config = {
			propValidation = true,
		}

		GlobalConfig.scoped(config, function()
			local MyComponent = Component:extend("MyComponent")

			local validatePropsSpy = createSpy(function()
				return true
			end)

			MyComponent.validateProps = validatePropsSpy.value

			function MyComponent:render()
				return nil
			end

			local element = createElement(MyComponent, { a = 1 })
			local hostParent = nil
			local key = "Test"

			local node = noopReconciler.mountVirtualNode(element, hostParent, key)
			expect(validatePropsSpy.callCount).to.equal(1)
			validatePropsSpy:assertCalledWithDeepEqual({
				a = 1,
			})

			local newElement = createElement(MyComponent, { a = 2 })
			noopReconciler.updateVirtualNode(node, newElement)
			expect(validatePropsSpy.callCount).to.equal(2)
			validatePropsSpy:assertCalledWithDeepEqual({
				a = 2,
			})
		end)
	end)

	it("should not be invoked when state changes", function()
		local config = {
			propValidation = true,
		}

		GlobalConfig.scoped(config, function()
			local MyComponent = Component:extend("MyComponent")

			local setStateCallback = nil
			local validatePropsSpy = createSpy(function()
				return true
			end)

			MyComponent.validateProps = validatePropsSpy.value

			function MyComponent:init()
				setStateCallback = function(newState)
					self:setState(newState)
				end
			end

			function MyComponent:render()
				return nil
			end

			local element = createElement(MyComponent, { a = 1 })
			local hostParent = nil
			local key = "Test"

			noopReconciler.mountVirtualNode(element, hostParent, key)
			expect(validatePropsSpy.callCount).to.equal(1)
			validatePropsSpy:assertCalledWithDeepEqual({
				a = 1,
			})

			setStateCallback({
				b = 1,
			})

			expect(validatePropsSpy.callCount).to.equal(1)
		end)
	end)

	it("should throw if validateProps is not a function", function()
		local config = {
			propValidation = true,
		}

		GlobalConfig.scoped(config, function()
			local MyComponent = Component:extend("MyComponent")
			MyComponent.validateProps = 1

			function MyComponent:render()
				return nil
			end

			local element = createElement(MyComponent)
			local hostParent = nil
			local key = "Test"

			expect(function()
				noopReconciler.mountVirtualNode(element, hostParent, key)
			end).to.throw()
		end)
	end)

	it("should throw if validateProps returns false", function()
		local config = {
			propValidation = true,
		}

		GlobalConfig.scoped(config, function()
			local MyComponent = Component:extend("MyComponent")
			MyComponent.validateProps = function()
				return false
			end

			function MyComponent:render()
				return nil
			end

			local element = createElement(MyComponent)
			local hostParent = nil
			local key = "Test"

			expect(function()
				noopReconciler.mountVirtualNode(element, hostParent, key)
			end).to.throw()
		end)
	end)

	it("should include the component name in the error message", function()
		local config = {
			propValidation = true,
		}

		GlobalConfig.scoped(config, function()
			local MyComponent = Component:extend("MyComponent")
			MyComponent.validateProps = function()
				return false
			end

			function MyComponent:render()
				return nil
			end

			local element = createElement(MyComponent)
			local hostParent = nil
			local key = "Test"

			local success, error = pcall(function()
				noopReconciler.mountVirtualNode(element, hostParent, key)
			end)

			expect(success).to.equal(false)
			local startIndex = error:find("MyComponent")
			expect(startIndex).to.be.ok()
		end)
	end)

	it("should be invoked after defaultProps are applied", function()
		local config = {
			propValidation = true,
		}

		GlobalConfig.scoped(config, function()
			local MyComponent = Component:extend("MyComponent")

			local validatePropsSpy = createSpy(function()
				return true
			end)

			MyComponent.validateProps = validatePropsSpy.value

			function MyComponent:render()
				return nil
			end

			MyComponent.defaultProps = {
				b = 2,
			}

			local element = createElement(MyComponent, { a = 1 })
			local hostParent = nil
			local key = "Test"

			local node = noopReconciler.mountVirtualNode(element, hostParent, key)
			expect(validatePropsSpy.callCount).to.equal(1)
			validatePropsSpy:assertCalledWithDeepEqual({
				a = 1,
				b = 2,
			})

			local newElement = createElement(MyComponent, { a = 2 })
			noopReconciler.updateVirtualNode(node, newElement)
			expect(validatePropsSpy.callCount).to.equal(2)
			validatePropsSpy:assertCalledWithDeepEqual({
				a = 2,
				b = 2,
			})
		end)
	end)

	it("should not be invoked if the flag is off", function()
		local config = {
			propValidation = false,
		}

		GlobalConfig.scoped(config, function()
			local MyComponent = Component:extend("MyComponent")

			local validatePropsSpy = createSpy(function()
				return true
			end)

			MyComponent.validateProps = validatePropsSpy.value

			function MyComponent:render()
				return nil
			end

			local element = createElement(MyComponent, { a = 1 })
			local hostParent = nil
			local key = "Test"

			local node = noopReconciler.mountVirtualNode(element, hostParent, key)
			expect(validatePropsSpy.callCount).to.equal(0)

			local newElement = createElement(MyComponent, { a = 2 })
			noopReconciler.updateVirtualNode(node, newElement)
			expect(validatePropsSpy.callCount).to.equal(0)
		end)
	end)
end ]]
_bc24a22c68c00f094ac68169d455a73a.Children["_a53894be1db05cc20eda1aa9f3d205ac"] = _a53894be1db05cc20eda1aa9f3d205ac
local _a53894be1db05cc20eda1aa9f3d205ac = nil -- DEALLOCATE PLS :pray:

local _162729d2b17518d93490c9b7372594e8 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_162729d2b17518d93490c9b7372594e8.Name = "willUnmount.spec"
_162729d2b17518d93490c9b7372594e8.Properties.Source = [[ return function()
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local createSpy = require(script.Parent.Parent.createSpy)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)
	local Type = require(script.Parent.Parent.Type)

	local Component = require(script.Parent.Parent.Component)

	local noopReconciler = createReconciler(NoopRenderer)

	it("should be invoked when unmounted", function()
		local MyComponent = Component:extend("MyComponent")

		local willUnmountSpy = createSpy()

		MyComponent.willUnmount = willUnmountSpy.value

		function MyComponent:render()
			return nil
		end

		local element = createElement(MyComponent)
		local hostParent = nil
		local key = "Test"

		local node = noopReconciler.mountVirtualNode(element, hostParent, key)
		noopReconciler.unmountVirtualNode(node)

		expect(willUnmountSpy.callCount).to.equal(1)

		local values = willUnmountSpy:captureValues("self")

		expect(Type.of(values.self)).to.equal(Type.StatefulComponentInstance)
	end)
end ]]
_bc24a22c68c00f094ac68169d455a73a.Children["_162729d2b17518d93490c9b7372594e8"] = _162729d2b17518d93490c9b7372594e8
local _162729d2b17518d93490c9b7372594e8 = nil -- DEALLOCATE PLS :pray:

local _e817a0b97cee5c016ee17f6b7005e9cb = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_e817a0b97cee5c016ee17f6b7005e9cb.Name = "willUpdate.spec"
_e817a0b97cee5c016ee17f6b7005e9cb.Properties.Source = [[ return function()
	local assertDeepEqual = require(script.Parent.Parent.assertDeepEqual)
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local createSpy = require(script.Parent.Parent.createSpy)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)
	local Type = require(script.Parent.Parent.Type)

	local Component = require(script.Parent.Parent.Component)

	local noopReconciler = createReconciler(NoopRenderer)

	it("should be invoked when updated via updateVirtualNode", function()
		local MyComponent = Component:extend("MyComponent")

		local willUpdateSpy = createSpy()

		MyComponent.willUpdate = willUpdateSpy.value

		function MyComponent:render()
			return nil
		end

		local initialProps = {
			a = 5,
		}
		local initialElement = createElement(MyComponent, initialProps)
		local hostParent = nil
		local key = "Test"

		local node = noopReconciler.mountVirtualNode(initialElement, hostParent, key)

		local newProps = {
			a = 6,
			b = 2,
		}
		local newElement = createElement(MyComponent, newProps)
		noopReconciler.updateVirtualNode(node, newElement)

		expect(willUpdateSpy.callCount).to.equal(1)

		local values = willUpdateSpy:captureValues("self", "newProps", "newState")

		expect(Type.of(values.self)).to.equal(Type.StatefulComponentInstance)
		assertDeepEqual(values.newProps, newProps)
		assertDeepEqual(values.newState, {})
	end)

	it("it should be invoked when updated via setState", function()
		local MyComponent = Component:extend("MyComponent")
		local setComponentState

		local willUpdateSpy = createSpy()

		MyComponent.willUpdate = willUpdateSpy.value

		function MyComponent:init()
			setComponentState = function(state)
				self:setState(state)
			end

			self:setState({
				foo = 1,
			})
		end

		function MyComponent:render()
			return nil
		end

		local initialElement = createElement(MyComponent)
		local hostParent = nil
		local key = "Test"

		noopReconciler.mountVirtualNode(initialElement, hostParent, key)

		expect(willUpdateSpy.callCount).to.equal(0)

		setComponentState({
			foo = 2,
		})

		expect(willUpdateSpy.callCount).to.equal(1)

		local values = willUpdateSpy:captureValues("self", "newProps", "newState")

		expect(Type.of(values.self)).to.equal(Type.StatefulComponentInstance)
		assertDeepEqual(values.newProps, {})
		assertDeepEqual(values.newState, {
			foo = 2,
		})
	end)
end ]]
_bc24a22c68c00f094ac68169d455a73a.Children["_e817a0b97cee5c016ee17f6b7005e9cb"] = _e817a0b97cee5c016ee17f6b7005e9cb
local _e817a0b97cee5c016ee17f6b7005e9cb = nil -- DEALLOCATE PLS :pray:

local _5962e589bb0e3ff6d881748c3369c008 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_5962e589bb0e3ff6d881748c3369c008.Name = "ComponentLifecyclePhase"
_5962e589bb0e3ff6d881748c3369c008.Properties.Source = [[ local Symbol = require(script.Parent.Symbol)
local strict = require(script.Parent.strict)

local ComponentLifecyclePhase = strict({
	-- Component methods
	Init = Symbol.named("init"),
	Render = Symbol.named("render"),
	ShouldUpdate = Symbol.named("shouldUpdate"),
	WillUpdate = Symbol.named("willUpdate"),
	DidMount = Symbol.named("didMount"),
	DidUpdate = Symbol.named("didUpdate"),
	WillUnmount = Symbol.named("willUnmount"),

	-- Phases describing reconciliation status
	ReconcileChildren = Symbol.named("reconcileChildren"),
	Idle = Symbol.named("idle"),
}, "ComponentLifecyclePhase")

return ComponentLifecyclePhase ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_5962e589bb0e3ff6d881748c3369c008"] = _5962e589bb0e3ff6d881748c3369c008
local _5962e589bb0e3ff6d881748c3369c008 = nil -- DEALLOCATE PLS :pray:

local _a1bb5a55b0ea7ff8eebe6f53a6c24702 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_a1bb5a55b0ea7ff8eebe6f53a6c24702.Name = "Config"
_a1bb5a55b0ea7ff8eebe6f53a6c24702.Properties.Source = [[ --\[\[
	Exposes an interface to set global configuration values for Roact.

	Configuration can only occur once, and should only be done by an application
	using Roact, not a library.

	Any keys that aren't recognized will cause errors. Configuration is only
	intended for configuring Roact itself, not extensions or libraries.

	Configuration is expected to be set immediately after loading Roact. Setting
	configuration values after an application starts may produce unpredictable
	behavior.
\]\]

-- Every valid configuration value should be non-nil in this table.
local defaultConfig = {
	-- Enables asserts for internal Roact APIs. Useful for debugging Roact itself.
	["internalTypeChecks"] = false,
	-- Enables stricter type asserts for Roact's public API.
	["typeChecks"] = false,
	-- Enables storage of `debug.traceback()` values on elements for debugging.
	["elementTracing"] = false,
	-- Enables validation of component props in stateful components.
	["propValidation"] = false,
}

-- Build a list of valid configuration values up for debug messages.
local defaultConfigKeys = {}
for key in pairs(defaultConfig) do
	table.insert(defaultConfigKeys, key)
end

local Config = {}

function Config.new()
	local self = {}

	self._currentConfig = setmetatable({}, {
		__index = function(_, key)
			local message = ("Invalid global configuration key %q. Valid configuration keys are: %s"):format(
				tostring(key),
				table.concat(defaultConfigKeys, ", ")
			)

			error(message, 3)
		end,
	})

	-- We manually bind these methods here so that the Config's methods can be
	-- used without passing in self, since they eventually get exposed on the
	-- root Roact object.
	self.set = function(...)
		return Config.set(self, ...)
	end

	self.get = function(...)
		return Config.get(self, ...)
	end

	self.scoped = function(...)
		return Config.scoped(self, ...)
	end

	self.set(defaultConfig)

	return self
end

function Config:set(configValues)
	-- Validate values without changing any configuration.
	-- We only want to apply this configuration if it's valid!
	for key, value in pairs(configValues) do
		if defaultConfig[key] == nil then
			local message = ("Invalid global configuration key %q (type %s). Valid configuration keys are: %s"):format(
				tostring(key),
				typeof(key),
				table.concat(defaultConfigKeys, ", ")
			)

			error(message, 3)
		end

		-- Right now, all configuration values must be boolean.
		if typeof(value) ~= "boolean" then
			local message = (
				"Invalid value %q (type %s) for global configuration key %q. Valid values are: true, false"
			):format(tostring(value), typeof(value), tostring(key))

			error(message, 3)
		end

		self._currentConfig[key] = value
	end
end

function Config:get()
	return self._currentConfig
end

function Config:scoped(configValues, callback)
	local previousValues = {}
	for key, value in pairs(self._currentConfig) do
		previousValues[key] = value
	end

	self.set(configValues)

	local success, result = pcall(callback)

	self.set(previousValues)

	assert(success, result)
end

return Config ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_a1bb5a55b0ea7ff8eebe6f53a6c24702"] = _a1bb5a55b0ea7ff8eebe6f53a6c24702
local _a1bb5a55b0ea7ff8eebe6f53a6c24702 = nil -- DEALLOCATE PLS :pray:

local _517cc3af8b6acd296d4c8ea6b1028c95 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_517cc3af8b6acd296d4c8ea6b1028c95.Name = "Config.spec"
_517cc3af8b6acd296d4c8ea6b1028c95.Properties.Source = [[ return function()
	local Config = require(script.Parent.Config)

	it("should accept valid configuration", function()
		local config = Config.new()
		local values = config.get()

		expect(values.elementTracing).to.equal(false)

		config.set({
			elementTracing = true,
		})

		expect(values.elementTracing).to.equal(true)
	end)

	it("should reject invalid configuration keys", function()
		local config = Config.new()

		local badKey = "garblegoop"

		local ok, err = pcall(function()
			config.set({
				[badKey] = true,
			})
		end)

		expect(ok).to.equal(false)

		-- The error should mention our bad key somewhere.
		expect(err:find(badKey)).to.be.ok()
	end)

	it("should reject invalid configuration values", function()
		local config = Config.new()

		local goodKey = "elementTracing"
		local badValue = "Hello there!"

		local ok, err = pcall(function()
			config.set({
				[goodKey] = badValue,
			})
		end)

		expect(ok).to.equal(false)

		-- The error should mention both our key and value
		expect(err:find(goodKey)).to.be.ok()
		expect(err:find(badValue)).to.be.ok()
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_517cc3af8b6acd296d4c8ea6b1028c95"] = _517cc3af8b6acd296d4c8ea6b1028c95
local _517cc3af8b6acd296d4c8ea6b1028c95 = nil -- DEALLOCATE PLS :pray:

local _a3bd4882c0d59b1b25eecd96158cb03c = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_a3bd4882c0d59b1b25eecd96158cb03c.Name = "ElementKind"
_a3bd4882c0d59b1b25eecd96158cb03c.Properties.Source = [[ --\[\[
	Contains markers for annotating the type of an element.

	Use `ElementKind` as a key, and values from it as the value.

		local element = {
			[ElementKind] = ElementKind.Host,
		}
\]\]

local Symbol = require(script.Parent.Symbol)
local strict = require(script.Parent.strict)
local Portal = require(script.Parent.Portal)

local ElementKind = newproxy(true)

local ElementKindInternal = {
	Portal = Symbol.named("Portal"),
	Host = Symbol.named("Host"),
	Function = Symbol.named("Function"),
	Stateful = Symbol.named("Stateful"),
	Fragment = Symbol.named("Fragment"),
}

function ElementKindInternal.of(value)
	if typeof(value) ~= "table" then
		return nil
	end

	return value[ElementKind]
end

local componentTypesToKinds = {
	["string"] = ElementKindInternal.Host,
	["function"] = ElementKindInternal.Function,
	["table"] = ElementKindInternal.Stateful,
}

function ElementKindInternal.fromComponent(component)
	if component == Portal then
		return ElementKind.Portal
	else
		return componentTypesToKinds[typeof(component)]
	end
end

getmetatable(ElementKind).__index = ElementKindInternal

strict(ElementKindInternal, "ElementKind")

return ElementKind ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_a3bd4882c0d59b1b25eecd96158cb03c"] = _a3bd4882c0d59b1b25eecd96158cb03c
local _a3bd4882c0d59b1b25eecd96158cb03c = nil -- DEALLOCATE PLS :pray:

local _2daa18552b62dab6fac856422d4db56a = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_2daa18552b62dab6fac856422d4db56a.Name = "ElementKind.spec"
_2daa18552b62dab6fac856422d4db56a.Properties.Source = [[ return function()
	local Portal = require(script.Parent.Portal)
	local Component = require(script.Parent.Component)

	local ElementKind = require(script.Parent.ElementKind)

	describe("of", function()
		it("should return nil for non-table values", function()
			expect(ElementKind.of(nil)).to.equal(nil)
			expect(ElementKind.of(5)).to.equal(nil)
			expect(ElementKind.of(newproxy(true))).to.equal(nil)
		end)

		it("should return nil for table values without an ElementKind key", function()
			expect(ElementKind.of({})).to.equal(nil)
		end)

		it("should return the ElementKind from a table", function()
			local value = {
				[ElementKind] = ElementKind.Stateful,
			}

			expect(ElementKind.of(value)).to.equal(ElementKind.Stateful)
		end)
	end)

	describe("fromComponent", function()
		it("should handle host components", function()
			expect(ElementKind.fromComponent("foo")).to.equal(ElementKind.Host)
		end)

		it("should handle function components", function()
			local function foo() end

			expect(ElementKind.fromComponent(foo)).to.equal(ElementKind.Function)
		end)

		it("should handle stateful components", function()
			local Foo = Component:extend("Foo")

			expect(ElementKind.fromComponent(Foo)).to.equal(ElementKind.Stateful)
		end)

		it("should handle portals", function()
			expect(ElementKind.fromComponent(Portal)).to.equal(ElementKind.Portal)
		end)

		it("should return nil for invalid inputs", function()
			expect(ElementKind.fromComponent(5)).to.equal(nil)
			expect(ElementKind.fromComponent(newproxy(true))).to.equal(nil)
		end)
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_2daa18552b62dab6fac856422d4db56a"] = _2daa18552b62dab6fac856422d4db56a
local _2daa18552b62dab6fac856422d4db56a = nil -- DEALLOCATE PLS :pray:

local _2167ccd8deb5507a180ebedde25d7543 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_2167ccd8deb5507a180ebedde25d7543.Name = "ElementUtils"
_2167ccd8deb5507a180ebedde25d7543.Properties.Source = [[ --!strict
local Type = require(script.Parent.Type)
local Symbol = require(script.Parent.Symbol)

local function noop()
	return nil
end

local ElementUtils = {}

--\[\[
	A signal value indicating that a child should use its parent's key, because
	it has no key of its own.

	This occurs when you return only one element from a function component or
	stateful render function.
\]\]
ElementUtils.UseParentKey = Symbol.named("UseParentKey")

type Iterator<K, V> = ({ [K]: V }, K?) -> (K?, V?)
type Element = { [any]: any }
--\[\[
	Returns an iterator over the children of an element.
	`elementOrElements` may be one of:
	* a boolean
	* nil
	* a single element
	* a fragment
	* a table of elements

	If `elementOrElements` is a boolean or nil, this will return an iterator with
	zero elements.

	If `elementOrElements` is a single element, this will return an iterator with
	one element: a tuple where the first value is ElementUtils.UseParentKey, and
	the second is the value of `elementOrElements`.

	If `elementOrElements` is a fragment or a table, this will return an iterator
	over all the elements of the array.

	If `elementOrElements` is none of the above, this function will throw.
\]\]
function ElementUtils.iterateElements<K>(elementOrElements): (Iterator<K, Element>, any, nil)
	local richType = Type.of(elementOrElements)

	-- Single child
	if richType == Type.Element then
		local called = false

		return function(_, _)
			if called then
				return nil
			else
				called = true
				return ElementUtils.UseParentKey, elementOrElements
			end
		end
	end

	local regularType = typeof(elementOrElements)

	if elementOrElements == nil or regularType == "boolean" then
		return (noop :: any) :: Iterator<K, Element>
	end

	if regularType == "table" then
		return pairs(elementOrElements)
	end

	error("Invalid elements")
end

--\[\[
	Gets the child corresponding to a given key, respecting Roact's rules for
	children. Specifically:
	* If `elements` is nil or a boolean, this will return `nil`, regardless of
		the key given.
	* If `elements` is a single element, this will return `nil`, unless the key
		is ElementUtils.UseParentKey.
	* If `elements` is a table of elements, this will return `elements[key]`.
\]\]
function ElementUtils.getElementByKey(elements, hostKey)
	if elements == nil or typeof(elements) == "boolean" then
		return nil
	end

	if Type.of(elements) == Type.Element then
		if hostKey == ElementUtils.UseParentKey then
			return elements
		end

		return nil
	end

	if typeof(elements) == "table" then
		return elements[hostKey]
	end

	error("Invalid elements")
end

return ElementUtils ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_2167ccd8deb5507a180ebedde25d7543"] = _2167ccd8deb5507a180ebedde25d7543
local _2167ccd8deb5507a180ebedde25d7543 = nil -- DEALLOCATE PLS :pray:

local _d756d20a9069b71cd9061faa37e96fbd = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_d756d20a9069b71cd9061faa37e96fbd.Name = "ElementUtils.spec"
_d756d20a9069b71cd9061faa37e96fbd.Properties.Source = [[ return function()
	local ElementUtils = require(script.Parent.ElementUtils)
	local createElement = require(script.Parent.createElement)
	local createFragment = require(script.Parent.createFragment)
	local Type = require(script.Parent.Type)

	describe("iterateElements", function()
		it("should iterate once for a single child", function()
			local child = createElement("TextLabel")
			local iterator = ElementUtils.iterateElements(child)
			local iteratedKey, iteratedChild = iterator()
			-- For single elements, the key should be UseParentKey
			expect(iteratedKey).to.equal(ElementUtils.UseParentKey)
			expect(iteratedChild).to.equal(child)

			iteratedKey = iterator()
			expect(iteratedKey).to.equal(nil)
		end)

		it("should iterate over tables", function()
			local children = {
				a = createElement("TextLabel"),
				b = createElement("TextLabel"),
			}

			local seenChildren = {}
			local count = 0

			for key, child in ElementUtils.iterateElements(children) do
				expect(typeof(key)).to.equal("string")
				expect(Type.of(child)).to.equal(Type.Element)
				seenChildren[child] = key
				count = count + 1
			end

			expect(count).to.equal(2)
			expect(seenChildren[children.a]).to.equal("a")
			expect(seenChildren[children.b]).to.equal("b")
		end)

		it("should return a zero-element iterator for booleans", function()
			local booleanIterator = ElementUtils.iterateElements(false)
			expect(booleanIterator()).to.equal(nil)
		end)

		it("should return a zero-element iterator for nil", function()
			local nilIterator = ElementUtils.iterateElements(nil)
			expect(nilIterator()).to.equal(nil)
		end)

		it("should throw if given an illegal value", function()
			expect(function()
				ElementUtils.iterateElements(1)
			end).to.throw()
		end)
	end)

	describe("getElementByKey", function()
		it("should return nil for booleans", function()
			expect(ElementUtils.getElementByKey(true, "test")).to.equal(nil)
		end)

		it("should return nil for nil", function()
			expect(ElementUtils.getElementByKey(nil, "test")).to.equal(nil)
		end)

		describe("single elements", function()
			local element = createElement("TextLabel")

			it("should return the element if the key is UseParentKey", function()
				expect(ElementUtils.getElementByKey(element, ElementUtils.UseParentKey)).to.equal(element)
			end)

			it("should return nil if the key is not UseParentKey", function()
				expect(ElementUtils.getElementByKey(element, "test")).to.equal(nil)
			end)
		end)

		it("should return the corresponding element from a table", function()
			local children = {
				a = createElement("TextLabel"),
				b = createElement("TextLabel"),
			}

			expect(ElementUtils.getElementByKey(children, "a")).to.equal(children.a)
			expect(ElementUtils.getElementByKey(children, "b")).to.equal(children.b)
		end)

		it("should return nil if the key does not exist", function()
			local children = createFragment({})

			expect(ElementUtils.getElementByKey(children, "a")).to.equal(nil)
		end)
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_d756d20a9069b71cd9061faa37e96fbd"] = _d756d20a9069b71cd9061faa37e96fbd
local _d756d20a9069b71cd9061faa37e96fbd = nil -- DEALLOCATE PLS :pray:

local _30486cc0f84a8f43d6a8a8eba8db4ff4 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_30486cc0f84a8f43d6a8a8eba8db4ff4.Name = "GlobalConfig"
_30486cc0f84a8f43d6a8a8eba8db4ff4.Properties.Source = [[ --\[\[
	Exposes a single instance of a configuration as Roact's GlobalConfig.
\]\]

local Config = require(script.Parent.Config)

return Config.new() ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_30486cc0f84a8f43d6a8a8eba8db4ff4"] = _30486cc0f84a8f43d6a8a8eba8db4ff4
local _30486cc0f84a8f43d6a8a8eba8db4ff4 = nil -- DEALLOCATE PLS :pray:

local _3842fbdcb59033088c203c1eed4b1926 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_3842fbdcb59033088c203c1eed4b1926.Name = "GlobalConfig.spec"
_3842fbdcb59033088c203c1eed4b1926.Properties.Source = [[ return function()
	local GlobalConfig = require(script.Parent.GlobalConfig)

	it("should have the correct methods", function()
		expect(GlobalConfig).to.be.ok()
		expect(GlobalConfig.set).to.be.ok()
		expect(GlobalConfig.get).to.be.ok()
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_3842fbdcb59033088c203c1eed4b1926"] = _3842fbdcb59033088c203c1eed4b1926
local _3842fbdcb59033088c203c1eed4b1926 = nil -- DEALLOCATE PLS :pray:

local _fb139bb291f0e9fbd16f30a53fdef048 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_fb139bb291f0e9fbd16f30a53fdef048.Name = "Logging"
_fb139bb291f0e9fbd16f30a53fdef048.Properties.Source = [[ --\[\[
	Centralized place to handle logging. Lets us:
	- Unit test log output via `Logging.capture`
	- Disable verbose log messages when not debugging Roact

	This should be broken out into a separate library with the addition of
	scoping and logging configuration.
\]\]

-- Determines whether log messages will go to stdout/stderr
local outputEnabled = true

-- A set of LogInfo objects that should have messages inserted into them.
-- This is a set so that nested calls to Logging.capture will behave.
local collectors = {}

-- A set of all stack traces that have called warnOnce.
local onceUsedLocations = {}

--\[\[
	Indent a potentially multi-line string with the given number of tabs, in
	addition to any indentation the string already has.
\]\]
local function indent(source, indentLevel)
	local indentString = ("\t"):rep(indentLevel)

	return indentString .. source:gsub("\n", "\n" .. indentString)
end

--\[\[
	Indents a list of strings and then concatenates them together with newlines
	into a single string.
\]\]
local function indentLines(lines, indentLevel)
	local outputBuffer = {}

	for _, line in ipairs(lines) do
		table.insert(outputBuffer, indent(line, indentLevel))
	end

	return table.concat(outputBuffer, "\n")
end

local logInfoMetatable = {}

--\[\[
	Automatic coercion to strings for LogInfo objects to enable debugging them
	more easily.
\]\]
function logInfoMetatable:__tostring()
	local outputBuffer = { "LogInfo {" }

	local errorCount = #self.errors
	local warningCount = #self.warnings
	local infosCount = #self.infos

	if errorCount + warningCount + infosCount == 0 then
		table.insert(outputBuffer, "\t(no messages)")
	end

	if errorCount > 0 then
		table.insert(outputBuffer, ("\tErrors (%d) {"):format(errorCount))
		table.insert(outputBuffer, indentLines(self.errors, 2))
		table.insert(outputBuffer, "\t}")
	end

	if warningCount > 0 then
		table.insert(outputBuffer, ("\tWarnings (%d) {"):format(warningCount))
		table.insert(outputBuffer, indentLines(self.warnings, 2))
		table.insert(outputBuffer, "\t}")
	end

	if infosCount > 0 then
		table.insert(outputBuffer, ("\tInfos (%d) {"):format(infosCount))
		table.insert(outputBuffer, indentLines(self.infos, 2))
		table.insert(outputBuffer, "\t}")
	end

	table.insert(outputBuffer, "}")

	return table.concat(outputBuffer, "\n")
end

local function createLogInfo()
	local logInfo = {
		errors = {},
		warnings = {},
		infos = {},
	}

	setmetatable(logInfo, logInfoMetatable)

	return logInfo
end

local Logging = {}

--\[\[
	Invokes `callback`, capturing all output that happens during its execution.

	Output will not go to stdout or stderr and will instead be put into a
	LogInfo object that is returned. If `callback` throws, the error will be
	bubbled up to the caller of `Logging.capture`.
\]\]
function Logging.capture(callback)
	local collector = createLogInfo()

	local wasOutputEnabled = outputEnabled
	outputEnabled = false
	collectors[collector] = true

	local success, result = pcall(callback)

	collectors[collector] = nil
	outputEnabled = wasOutputEnabled

	assert(success, result)

	return collector
end

--\[\[
	Issues a warning with an automatically attached stack trace.
\]\]
function Logging.warn(messageTemplate, ...)
	local message = messageTemplate:format(...)

	for collector in pairs(collectors) do
		table.insert(collector.warnings, message)
	end

	-- debug.traceback inserts a leading newline, so we trim it here
	local trace = debug.traceback("", 2):sub(2)
	local fullMessage = ("%s\n%s"):format(message, indent(trace, 1))

	if outputEnabled then
		warn(fullMessage)
	end
end

--\[\[
	Issues a warning like `Logging.warn`, but only outputs once per call site.

	This is useful for marking deprecated functions that might be called a lot;
	using `warnOnce` instead of `warn` will reduce output noise while still
	correctly marking all call sites.
\]\]
function Logging.warnOnce(messageTemplate, ...)
	local trace = debug.traceback()

	if onceUsedLocations[trace] then
		return
	end

	onceUsedLocations[trace] = true
	Logging.warn(messageTemplate, ...)
end

return Logging ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_fb139bb291f0e9fbd16f30a53fdef048"] = _fb139bb291f0e9fbd16f30a53fdef048
local _fb139bb291f0e9fbd16f30a53fdef048 = nil -- DEALLOCATE PLS :pray:

local _a220abf016cebf8b003ff11ce50ff067 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_a220abf016cebf8b003ff11ce50ff067.Name = "None"
_a220abf016cebf8b003ff11ce50ff067.Properties.Source = [[ local Symbol = require(script.Parent.Symbol)

-- Marker used to specify that the value is nothing, because nil cannot be
-- stored in tables.
local None = Symbol.named("None")

return None ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_a220abf016cebf8b003ff11ce50ff067"] = _a220abf016cebf8b003ff11ce50ff067
local _a220abf016cebf8b003ff11ce50ff067 = nil -- DEALLOCATE PLS :pray:

local _2810b87aaf014881e161c2bd0fb84ae9 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_2810b87aaf014881e161c2bd0fb84ae9.Name = "NoopRenderer"
_2810b87aaf014881e161c2bd0fb84ae9.Properties.Source = [[ --\[\[
	Reference renderer intended for use in tests as well as for documenting the
	minimum required interface for a Roact renderer.
\]\]

local NoopRenderer = {}

function NoopRenderer.isHostObject(target)
	-- Attempting to use NoopRenderer to target a Roblox instance is almost
	-- certainly a mistake.
	return target == nil
end

function NoopRenderer.mountHostNode(_reconciler, _node) end

function NoopRenderer.unmountHostNode(_reconciler, _node) end

function NoopRenderer.updateHostNode(_reconciler, node, _newElement)
	return node
end

return NoopRenderer ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_2810b87aaf014881e161c2bd0fb84ae9"] = _2810b87aaf014881e161c2bd0fb84ae9
local _2810b87aaf014881e161c2bd0fb84ae9 = nil -- DEALLOCATE PLS :pray:

local _71b0af5b4e5b51759fae3b37b802fe24 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_71b0af5b4e5b51759fae3b37b802fe24.Name = "Portal"
_71b0af5b4e5b51759fae3b37b802fe24.Properties.Source = [[ local Symbol = require(script.Parent.Symbol)

local Portal = Symbol.named("Portal")

return Portal ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_71b0af5b4e5b51759fae3b37b802fe24"] = _71b0af5b4e5b51759fae3b37b802fe24
local _71b0af5b4e5b51759fae3b37b802fe24 = nil -- DEALLOCATE PLS :pray:

local _2a51e46d4b1eaa5d95065e7b3e9d28ec = { ClassName = "Folder", Children = {}, Properties = {} }
_2a51e46d4b1eaa5d95065e7b3e9d28ec.Name = "PropMarkers"
_4939180de2039ab164a0b6fd3ff1aed2.Children["_2a51e46d4b1eaa5d95065e7b3e9d28ec"] = _2a51e46d4b1eaa5d95065e7b3e9d28ec
local _2a51e46d4b1eaa5d95065e7b3e9d28ec = nil -- DEALLOCATE PLS :pray:
local _ccd74a184c02aa79259afe7a93981e70 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_ccd74a184c02aa79259afe7a93981e70.Name = "Change"
_ccd74a184c02aa79259afe7a93981e70.Properties.Source = [[ --\[\[
	Change is used to generate special prop keys that can be used to connect to
	GetPropertyChangedSignal.

	Generally, Change is indexed by a Roblox property name:

		Roact.createElement("TextBox", {
			[Roact.Change.Text] = function(rbx)
				print("The TextBox", rbx, "changed text to", rbx.Text)
			end,
		})
\]\]

local Type = require(script.Parent.Parent.Type)

local Change = {}

local changeMetatable = {
	__tostring = function(self)
		return ("RoactHostChangeEvent(%s)"):format(self.name)
	end,
}

setmetatable(Change, {
	__index = function(_self, propertyName)
		local changeListener = {
			[Type] = Type.HostChangeEvent,
			name = propertyName,
		}

		setmetatable(changeListener, changeMetatable)
		Change[propertyName] = changeListener

		return changeListener
	end,
})

return Change ]]
_2a51e46d4b1eaa5d95065e7b3e9d28ec.Children["_ccd74a184c02aa79259afe7a93981e70"] = _ccd74a184c02aa79259afe7a93981e70
local _ccd74a184c02aa79259afe7a93981e70 = nil -- DEALLOCATE PLS :pray:

local _66cc4852eb6cc5a883a276f105f706aa = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_66cc4852eb6cc5a883a276f105f706aa.Name = "Change.spec"
_66cc4852eb6cc5a883a276f105f706aa.Properties.Source = [[ return function()
	local Type = require(script.Parent.Parent.Type)

	local Change = require(script.Parent.Change)

	it("should yield change listener objects when indexed", function()
		expect(Type.of(Change.Text)).to.equal(Type.HostChangeEvent)
		expect(Type.of(Change.Selected)).to.equal(Type.HostChangeEvent)
	end)

	it("should yield the same object when indexed again", function()
		local a = Change.Text
		local b = Change.Text
		local c = Change.Selected

		expect(a).to.equal(b)
		expect(a).never.to.equal(c)
	end)
end ]]
_2a51e46d4b1eaa5d95065e7b3e9d28ec.Children["_66cc4852eb6cc5a883a276f105f706aa"] = _66cc4852eb6cc5a883a276f105f706aa
local _66cc4852eb6cc5a883a276f105f706aa = nil -- DEALLOCATE PLS :pray:

local _d311b27e5f3f92b490eb1779a01011eb = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_d311b27e5f3f92b490eb1779a01011eb.Name = "Children"
_d311b27e5f3f92b490eb1779a01011eb.Properties.Source = [[ local Symbol = require(script.Parent.Parent.Symbol)

local Children = Symbol.named("Children")

return Children ]]
_2a51e46d4b1eaa5d95065e7b3e9d28ec.Children["_d311b27e5f3f92b490eb1779a01011eb"] = _d311b27e5f3f92b490eb1779a01011eb
local _d311b27e5f3f92b490eb1779a01011eb = nil -- DEALLOCATE PLS :pray:

local _d32b73fa19bd7335e63d1af4d9a3dafa = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_d32b73fa19bd7335e63d1af4d9a3dafa.Name = "Event"
_d32b73fa19bd7335e63d1af4d9a3dafa.Properties.Source = [[ --\[\[
	Index into `Event` to get a prop key for attaching to an event on a Roblox
	Instance.

	Example:

		Roact.createElement("TextButton", {
			Text = "Hello, world!",

			[Roact.Event.MouseButton1Click] = function(rbx)
				print("Clicked", rbx)
			end
		})
\]\]

local Type = require(script.Parent.Parent.Type)

local Event = {}

local eventMetatable = {
	__tostring = function(self)
		return ("RoactHostEvent(%s)"):format(self.name)
	end,
}

setmetatable(Event, {
	__index = function(_self, eventName)
		local event = {
			[Type] = Type.HostEvent,
			name = eventName,
		}

		setmetatable(event, eventMetatable)

		Event[eventName] = event

		return event
	end,
})

return Event ]]
_2a51e46d4b1eaa5d95065e7b3e9d28ec.Children["_d32b73fa19bd7335e63d1af4d9a3dafa"] = _d32b73fa19bd7335e63d1af4d9a3dafa
local _d32b73fa19bd7335e63d1af4d9a3dafa = nil -- DEALLOCATE PLS :pray:

local _bf05fc30c9f88c1f3ad07b6cc9288dea = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_bf05fc30c9f88c1f3ad07b6cc9288dea.Name = "Event.spec"
_bf05fc30c9f88c1f3ad07b6cc9288dea.Properties.Source = [[ return function()
	local Type = require(script.Parent.Parent.Type)

	local Event = require(script.Parent.Event)

	it("should yield event objects when indexed", function()
		expect(Type.of(Event.MouseButton1Click)).to.equal(Type.HostEvent)
		expect(Type.of(Event.Touched)).to.equal(Type.HostEvent)
	end)

	it("should yield the same object when indexed again", function()
		local a = Event.MouseButton1Click
		local b = Event.MouseButton1Click
		local c = Event.Touched

		expect(a).to.equal(b)
		expect(a).never.to.equal(c)
	end)
end ]]
_2a51e46d4b1eaa5d95065e7b3e9d28ec.Children["_bf05fc30c9f88c1f3ad07b6cc9288dea"] = _bf05fc30c9f88c1f3ad07b6cc9288dea
local _bf05fc30c9f88c1f3ad07b6cc9288dea = nil -- DEALLOCATE PLS :pray:

local _b6ae2b160d5c58083c0340b3c829d64b = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_b6ae2b160d5c58083c0340b3c829d64b.Name = "Ref"
_b6ae2b160d5c58083c0340b3c829d64b.Properties.Source = [[ local Symbol = require(script.Parent.Parent.Symbol)

local Ref = Symbol.named("Ref")

return Ref ]]
_2a51e46d4b1eaa5d95065e7b3e9d28ec.Children["_b6ae2b160d5c58083c0340b3c829d64b"] = _b6ae2b160d5c58083c0340b3c829d64b
local _b6ae2b160d5c58083c0340b3c829d64b = nil -- DEALLOCATE PLS :pray:

local _c3c26bd24d9ee7073957fdc11d82bdbf = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_c3c26bd24d9ee7073957fdc11d82bdbf.Name = "PureComponent"
_c3c26bd24d9ee7073957fdc11d82bdbf.Properties.Source = [[ --\[\[
	A version of Component with a `shouldUpdate` method that forces the
	resulting component to be pure.
\]\]

local Component = require(script.Parent.Component)

local PureComponent = Component:extend("PureComponent")

-- When extend()ing a component, you don't get an extend method.
-- This is to promote composition over inheritance.
-- PureComponent is an exception to this rule.
PureComponent.extend = Component.extend

function PureComponent:shouldUpdate(newProps, newState)
	-- In a vast majority of cases, if state updated, something has updated.
	-- We don't bother checking in this case.
	if newState ~= self.state then
		return true
	end

	if newProps == self.props then
		return false
	end

	for key, value in pairs(newProps) do
		if self.props[key] ~= value then
			return true
		end
	end

	for key, value in pairs(self.props) do
		if newProps[key] ~= value then
			return true
		end
	end

	return false
end

return PureComponent ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_c3c26bd24d9ee7073957fdc11d82bdbf"] = _c3c26bd24d9ee7073957fdc11d82bdbf
local _c3c26bd24d9ee7073957fdc11d82bdbf = nil -- DEALLOCATE PLS :pray:

local _0dddce1eb05ae17ca510b882fb377de3 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_0dddce1eb05ae17ca510b882fb377de3.Name = "PureComponent.spec"
_0dddce1eb05ae17ca510b882fb377de3.Properties.Source = [[ return function()
	local createElement = require(script.Parent.createElement)
	local NoopRenderer = require(script.Parent.NoopRenderer)
	local createReconciler = require(script.Parent.createReconciler)

	local PureComponent = require(script.Parent.PureComponent)

	local noopReconciler = createReconciler(NoopRenderer)

	it("should be extendable", function()
		local MyComponent = PureComponent:extend("MyComponent")

		expect(MyComponent).to.be.ok()
	end)

	it("should skip updates for shallow-equal props", function()
		local updateCount = 0
		local setValue

		local PureChild = PureComponent:extend("PureChild")

		function PureChild:willUpdate()
			updateCount = updateCount + 1
		end

		function PureChild:render()
			return nil
		end

		local PureContainer = PureComponent:extend("PureContainer")

		function PureContainer:init()
			self.state = {
				value = 0,
			}
		end

		function PureContainer:didMount()
			setValue = function(value)
				self:setState({
					value = value,
				})
			end
		end

		function PureContainer:render()
			return createElement(PureChild, {
				value = self.state.value,
			})
		end

		local element = createElement(PureContainer)
		local tree = noopReconciler.mountVirtualTree(element, nil, "PureComponent Tree")

		expect(updateCount).to.equal(0)

		setValue(1)

		expect(updateCount).to.equal(1)

		setValue(1)

		expect(updateCount).to.equal(1)

		setValue(2)

		expect(updateCount).to.equal(2)

		setValue(1)

		expect(updateCount).to.equal(3)

		noopReconciler.unmountVirtualTree(tree)
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_0dddce1eb05ae17ca510b882fb377de3"] = _0dddce1eb05ae17ca510b882fb377de3
local _0dddce1eb05ae17ca510b882fb377de3 = nil -- DEALLOCATE PLS :pray:

local _5b3ee5efe8e9be435d161bc77da24b76 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_5b3ee5efe8e9be435d161bc77da24b76.Name = "RobloxRenderer"
_5b3ee5efe8e9be435d161bc77da24b76.Properties.Source = [[ --\[\[
	Renderer that deals in terms of Roblox Instances. This is the most
	well-supported renderer after NoopRenderer and is currently the only
	renderer that does anything.
\]\]

local Binding = require(script.Parent.Binding)
local Children = require(script.Parent.PropMarkers.Children)
local ElementKind = require(script.Parent.ElementKind)
local SingleEventManager = require(script.Parent.SingleEventManager)
local getDefaultInstanceProperty = require(script.Parent.getDefaultInstanceProperty)
local Ref = require(script.Parent.PropMarkers.Ref)
local Type = require(script.Parent.Type)
local internalAssert = require(script.Parent.internalAssert)

local config = require(script.Parent.GlobalConfig).get()

local applyPropsError = \[\[
Error applying props:
	%s
In element:
%s
\]\]

local updatePropsError = \[\[
Error updating props:
	%s
In element:
%s
\]\]

local function identity(...)
	return ...
end

local function applyRef(ref, newHostObject)
	if ref == nil then
		return
	end

	if typeof(ref) == "function" then
		ref(newHostObject)
	elseif Type.of(ref) == Type.Binding then
		Binding.update(ref, newHostObject)
	else
		-- TODO (#197): Better error message
		error(("Invalid ref: Expected type Binding but got %s"):format(typeof(ref)))
	end
end

local function setRobloxInstanceProperty(hostObject, key, newValue)
	if newValue == nil then
		local hostClass = hostObject.ClassName
		local _, defaultValue = getDefaultInstanceProperty(hostClass, key)
		newValue = defaultValue
	end

	-- Assign the new value to the object
	hostObject[key] = newValue

	return
end

local function removeBinding(virtualNode, key)
	local disconnect = virtualNode.bindings[key]
	disconnect()
	virtualNode.bindings[key] = nil
end

local function attachBinding(virtualNode, key, newBinding)
	local function updateBoundProperty(newValue)
		local success, errorMessage = xpcall(function()
			setRobloxInstanceProperty(virtualNode.hostObject, key, newValue)
		end, identity)

		if not success then
			local source = virtualNode.currentElement.source

			if source == nil then
				source = "<enable element tracebacks>"
			end

			local fullMessage = updatePropsError:format(errorMessage, source)
			error(fullMessage, 0)
		end
	end

	if virtualNode.bindings == nil then
		virtualNode.bindings = {}
	end

	virtualNode.bindings[key] = Binding.subscribe(newBinding, updateBoundProperty)

	updateBoundProperty(newBinding:getValue())
end

local function detachAllBindings(virtualNode)
	if virtualNode.bindings ~= nil then
		for _, disconnect in pairs(virtualNode.bindings) do
			disconnect()
		end
		virtualNode.bindings = nil
	end
end

local function applyProp(virtualNode, key, newValue, oldValue)
	if newValue == oldValue then
		return
	end

	if key == Ref or key == Children then
		-- Refs and children are handled in a separate pass
		return
	end

	local internalKeyType = Type.of(key)

	if internalKeyType == Type.HostEvent or internalKeyType == Type.HostChangeEvent then
		if virtualNode.eventManager == nil then
			virtualNode.eventManager = SingleEventManager.new(virtualNode.hostObject)
		end

		local eventName = key.name

		if internalKeyType == Type.HostChangeEvent then
			virtualNode.eventManager:connectPropertyChange(eventName, newValue)
		else
			virtualNode.eventManager:connectEvent(eventName, newValue)
		end

		return
	end

	local newIsBinding = Type.of(newValue) == Type.Binding
	local oldIsBinding = Type.of(oldValue) == Type.Binding

	if oldIsBinding then
		removeBinding(virtualNode, key)
	end

	if newIsBinding then
		attachBinding(virtualNode, key, newValue)
	else
		setRobloxInstanceProperty(virtualNode.hostObject, key, newValue)
	end
end

local function applyProps(virtualNode, props)
	for propKey, value in pairs(props) do
		applyProp(virtualNode, propKey, value, nil)
	end
end

local function updateProps(virtualNode, oldProps, newProps)
	-- Apply props that were added or updated
	for propKey, newValue in pairs(newProps) do
		local oldValue = oldProps[propKey]

		applyProp(virtualNode, propKey, newValue, oldValue)
	end

	-- Clean up props that were removed
	for propKey, oldValue in pairs(oldProps) do
		local newValue = newProps[propKey]

		if newValue == nil then
			applyProp(virtualNode, propKey, nil, oldValue)
		end
	end
end

local RobloxRenderer = {}

function RobloxRenderer.isHostObject(target)
	return typeof(target) == "Instance"
end

function RobloxRenderer.mountHostNode(reconciler, virtualNode)
	local element = virtualNode.currentElement
	local hostParent = virtualNode.hostParent
	local hostKey = virtualNode.hostKey

	if config.internalTypeChecks then
		internalAssert(ElementKind.of(element) == ElementKind.Host, "Element at given node is not a host Element")
	end
	if config.typeChecks then
		assert(element.props.Name == nil, "Name can not be specified as a prop to a host component in Roact.")
		assert(element.props.Parent == nil, "Parent can not be specified as a prop to a host component in Roact.")
	end

	local instance = Instance.new(element.component)
	virtualNode.hostObject = instance

	local success, errorMessage = xpcall(function()
		applyProps(virtualNode, element.props)
	end, identity)

	if not success then
		local source = element.source

		if source == nil then
			source = "<enable element tracebacks>"
		end

		local fullMessage = applyPropsError:format(errorMessage, source)
		error(fullMessage, 0)
	end

	instance.Name = tostring(hostKey)

	local children = element.props[Children]

	if children ~= nil then
		reconciler.updateVirtualNodeWithChildren(virtualNode, virtualNode.hostObject, children)
	end

	instance.Parent = hostParent
	virtualNode.hostObject = instance

	applyRef(element.props[Ref], instance)

	if virtualNode.eventManager ~= nil then
		virtualNode.eventManager:resume()
	end
end

function RobloxRenderer.unmountHostNode(reconciler, virtualNode)
	local element = virtualNode.currentElement

	applyRef(element.props[Ref], nil)

	for _, childNode in pairs(virtualNode.children) do
		reconciler.unmountVirtualNode(childNode)
	end

	detachAllBindings(virtualNode)

	virtualNode.hostObject:Destroy()
end

function RobloxRenderer.updateHostNode(reconciler, virtualNode, newElement)
	local oldProps = virtualNode.currentElement.props
	local newProps = newElement.props

	if virtualNode.eventManager ~= nil then
		virtualNode.eventManager:suspend()
	end

	-- If refs changed, detach the old ref and attach the new one
	if oldProps[Ref] ~= newProps[Ref] then
		applyRef(oldProps[Ref], nil)
		applyRef(newProps[Ref], virtualNode.hostObject)
	end

	local success, errorMessage = xpcall(function()
		updateProps(virtualNode, oldProps, newProps)
	end, identity)

	if not success then
		local source = newElement.source

		if source == nil then
			source = "<enable element tracebacks>"
		end

		local fullMessage = updatePropsError:format(errorMessage, source)
		error(fullMessage, 0)
	end

	local children = newElement.props[Children]
	if children ~= nil or oldProps[Children] ~= nil then
		reconciler.updateVirtualNodeWithChildren(virtualNode, virtualNode.hostObject, children)
	end

	if virtualNode.eventManager ~= nil then
		virtualNode.eventManager:resume()
	end

	return virtualNode
end

return RobloxRenderer ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_5b3ee5efe8e9be435d161bc77da24b76"] = _5b3ee5efe8e9be435d161bc77da24b76
local _5b3ee5efe8e9be435d161bc77da24b76 = nil -- DEALLOCATE PLS :pray:

local _dd162c2155e9d9c4c065e5baee5e7bda = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_dd162c2155e9d9c4c065e5baee5e7bda.Name = "RobloxRenderer.spec"
_dd162c2155e9d9c4c065e5baee5e7bda.Properties.Source = [[ return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local assertDeepEqual = require(script.Parent.assertDeepEqual)
	local Binding = require(script.Parent.Binding)
	local Children = require(script.Parent.PropMarkers.Children)
	local Component = require(script.Parent.Component)
	local createElement = require(script.Parent.createElement)
	local createFragment = require(script.Parent.createFragment)
	local createReconciler = require(script.Parent.createReconciler)
	local createRef = require(script.Parent.createRef)
	local createSpy = require(script.Parent.createSpy)
	local GlobalConfig = require(script.Parent.GlobalConfig)
	local Portal = require(script.Parent.Portal)
	local Ref = require(script.Parent.PropMarkers.Ref)
	local Event = require(script.Parent.PropMarkers.Event)

	local RobloxRenderer = require(script.Parent.RobloxRenderer)

	local reconciler = createReconciler(RobloxRenderer)

	describe("mountHostNode", function()
		it("should create instances with correct props", function()
			local parent = Instance.new("Folder")
			local value = "Hello!"
			local key = "Some Key"

			local element = createElement("StringValue", {
				Value = value,
			})

			local node = reconciler.createVirtualNode(element, parent, key)

			RobloxRenderer.mountHostNode(reconciler, node)

			expect(#parent:GetChildren()).to.equal(1)

			local root = parent:GetChildren()[1]

			expect(root.ClassName).to.equal("StringValue")
			expect(root.Value).to.equal(value)
			expect(root.Name).to.equal(key)
		end)

		it("should create children with correct names and props", function()
			local parent = Instance.new("Folder")
			local rootValue = "Hey there!"
			local childValue = 173
			local key = "Some Key"

			local element = createElement("StringValue", {
				Value = rootValue,
			}, {
				ChildA = createElement("IntValue", {
					Value = childValue,
				}),

				ChildB = createElement("Folder"),
			})

			local node = reconciler.createVirtualNode(element, parent, key)

			RobloxRenderer.mountHostNode(reconciler, node)

			expect(#parent:GetChildren()).to.equal(1)

			local root = parent:GetChildren()[1]

			expect(root.ClassName).to.equal("StringValue")
			expect(root.Value).to.equal(rootValue)
			expect(root.Name).to.equal(key)

			expect(#root:GetChildren()).to.equal(2)

			local childA = root.ChildA
			local childB = root.ChildB

			expect(childA).to.be.ok()
			expect(childB).to.be.ok()

			expect(childA.ClassName).to.equal("IntValue")
			expect(childA.Value).to.equal(childValue)

			expect(childB.ClassName).to.equal("Folder")
		end)

		it("should attach Bindings to Roblox properties", function()
			local parent = Instance.new("Folder")
			local key = "Some Key"

			local binding, update = Binding.create(10)
			local element = createElement("IntValue", {
				Value = binding,
			})

			local node = reconciler.createVirtualNode(element, parent, key)

			RobloxRenderer.mountHostNode(reconciler, node)

			expect(#parent:GetChildren()).to.equal(1)

			local instance = parent:GetChildren()[1]

			expect(instance.ClassName).to.equal("IntValue")
			expect(instance.Value).to.equal(10)

			update(20)

			expect(instance.Value).to.equal(20)

			RobloxRenderer.unmountHostNode(reconciler, node)
		end)

		it("should connect Binding refs", function()
			local parent = Instance.new("Folder")
			local key = "Some Key"

			local ref = createRef()
			local element = createElement("Frame", {
				[Ref] = ref,
			})

			local node = reconciler.createVirtualNode(element, parent, key)

			RobloxRenderer.mountHostNode(reconciler, node)

			expect(#parent:GetChildren()).to.equal(1)

			local instance = parent:GetChildren()[1]

			expect(ref.current).to.be.ok()
			expect(ref.current).to.equal(instance)

			RobloxRenderer.unmountHostNode(reconciler, node)
		end)

		it("should call function refs", function()
			local parent = Instance.new("Folder")
			local key = "Some Key"

			local spyRef = createSpy()
			local element = createElement("Frame", {
				[Ref] = spyRef.value,
			})

			local node = reconciler.createVirtualNode(element, parent, key)

			RobloxRenderer.mountHostNode(reconciler, node)

			expect(#parent:GetChildren()).to.equal(1)

			local instance = parent:GetChildren()[1]

			expect(spyRef.callCount).to.equal(1)
			spyRef:assertCalledWith(instance)

			RobloxRenderer.unmountHostNode(reconciler, node)
		end)

		it("should throw if setting invalid instance properties", function()
			local configValues = {
				elementTracing = true,
			}

			GlobalConfig.scoped(configValues, function()
				local parent = Instance.new("Folder")
				local key = "Some Key"

				local element = createElement("Frame", {
					Frob = 6,
				})

				local node = reconciler.createVirtualNode(element, parent, key)

				local success, message = pcall(RobloxRenderer.mountHostNode, reconciler, node)
				assert(not success, "Expected call to fail")

				expect(message:find("Frob")).to.be.ok()
				expect(message:find("Frame")).to.be.ok()
				expect(message:find("RobloxRenderer%.spec")).to.be.ok()
			end)
		end)
	end)

	describe("updateHostNode", function()
		it("should update node props and children", function()
			-- TODO: Break up test

			local parent = Instance.new("Folder")
			local key = "updateHostNodeTest"
			local firstValue = "foo"
			local newValue = "bar"

			local defaultStringValue = Instance.new("StringValue").Value

			local element = createElement("StringValue", {
				Value = firstValue,
			}, {
				ChildA = createElement("IntValue", {
					Value = 1,
				}),
				ChildB = createElement("BoolValue", {
					Value = true,
				}),
				ChildC = createElement("StringValue", {
					Value = "test",
				}),
				ChildD = createElement("StringValue", {
					Value = "test",
				}),
			})

			local node = reconciler.createVirtualNode(element, parent, key)
			RobloxRenderer.mountHostNode(reconciler, node)

			-- Not testing mountHostNode's work here, only testing that the
			-- node is properly updated.

			local newElement = createElement("StringValue", {
				Value = newValue,
			}, {
				-- ChildA changes element type.
				ChildA = createElement("StringValue", {
					Value = "test",
				}),
				-- ChildB changes child properties.
				ChildB = createElement("BoolValue", {
					Value = false,
				}),
				-- ChildC should reset its Value property back to the default.
				ChildC = createElement("StringValue", {}),
				-- ChildD is deleted.
				-- ChildE is added.
				ChildE = createElement("Folder", {}),
			})

			RobloxRenderer.updateHostNode(reconciler, node, newElement)

			local root = parent[key]
			expect(root.ClassName).to.equal("StringValue")
			expect(root.Value).to.equal(newValue)
			expect(#root:GetChildren()).to.equal(4)

			local childA = root.ChildA
			expect(childA.ClassName).to.equal("StringValue")
			expect(childA.Value).to.equal("test")

			local childB = root.ChildB
			expect(childB.ClassName).to.equal("BoolValue")
			expect(childB.Value).to.equal(false)

			local childC = root.ChildC
			expect(childC.ClassName).to.equal("StringValue")
			expect(childC.Value).to.equal(defaultStringValue)

			local childE = root.ChildE
			expect(childE.ClassName).to.equal("Folder")
		end)

		it("should update Bindings", function()
			local parent = Instance.new("Folder")
			local key = "Some Key"

			local bindingA, updateA = Binding.create(10)
			local element = createElement("IntValue", {
				Value = bindingA,
			})

			local node = reconciler.createVirtualNode(element, parent, key)

			RobloxRenderer.mountHostNode(reconciler, node)

			local instance = parent:GetChildren()[1]

			expect(instance.Value).to.equal(10)

			local bindingB, updateB = Binding.create(99)
			local newElement = createElement("IntValue", {
				Value = bindingB,
			})

			RobloxRenderer.updateHostNode(reconciler, node, newElement)

			expect(instance.Value).to.equal(99)

			updateA(123)

			expect(instance.Value).to.equal(99)

			updateB(123)

			expect(instance.Value).to.equal(123)

			RobloxRenderer.unmountHostNode(reconciler, node)
		end)

		it("should update Binding refs", function()
			local parent = Instance.new("Folder")
			local key = "Some Key"

			local refA = createRef()
			local refB = createRef()

			local element = createElement("Frame", {
				[Ref] = refA,
			})

			local node = reconciler.createVirtualNode(element, parent, key)

			RobloxRenderer.mountHostNode(reconciler, node)

			expect(#parent:GetChildren()).to.equal(1)

			local instance = parent:GetChildren()[1]

			expect(refA.current).to.equal(instance)
			expect(refB.current).never.to.be.ok()

			local newElement = createElement("Frame", {
				[Ref] = refB,
			})

			RobloxRenderer.updateHostNode(reconciler, node, newElement)

			expect(refA.current).never.to.be.ok()
			expect(refB.current).to.equal(instance)

			RobloxRenderer.unmountHostNode(reconciler, node)
		end)

		it("should call old function refs with nil and new function refs with a valid rbx", function()
			local parent = Instance.new("Folder")
			local key = "Some Key"

			local spyRefA = createSpy()
			local spyRefB = createSpy()

			local element = createElement("Frame", {
				[Ref] = spyRefA.value,
			})

			local node = reconciler.createVirtualNode(element, parent, key)

			RobloxRenderer.mountHostNode(reconciler, node)

			expect(#parent:GetChildren()).to.equal(1)

			local instance = parent:GetChildren()[1]

			expect(spyRefA.callCount).to.equal(1)
			spyRefA:assertCalledWith(instance)
			expect(spyRefB.callCount).to.equal(0)

			local newElement = createElement("Frame", {
				[Ref] = spyRefB.value,
			})

			RobloxRenderer.updateHostNode(reconciler, node, newElement)

			expect(spyRefA.callCount).to.equal(2)
			spyRefA:assertCalledWith(nil)
			expect(spyRefB.callCount).to.equal(1)
			spyRefB:assertCalledWith(instance)

			RobloxRenderer.unmountHostNode(reconciler, node)
		end)

		it("should not call function refs again if they didn't change", function()
			local parent = Instance.new("Folder")
			local key = "Some Key"

			local spyRef = createSpy()

			local element = createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				[Ref] = spyRef.value,
			})

			local node = reconciler.createVirtualNode(element, parent, key)

			RobloxRenderer.mountHostNode(reconciler, node)

			expect(#parent:GetChildren()).to.equal(1)

			local instance = parent:GetChildren()[1]

			expect(spyRef.callCount).to.equal(1)
			spyRef:assertCalledWith(instance)

			local newElement = createElement("Frame", {
				Size = UDim2.new(0.5, 0, 0.5, 0),
				[Ref] = spyRef.value,
			})

			RobloxRenderer.updateHostNode(reconciler, node, newElement)

			-- Not called again
			expect(spyRef.callCount).to.equal(1)
		end)

		it("should throw if setting invalid instance properties", function()
			local configValues = {
				elementTracing = true,
			}

			GlobalConfig.scoped(configValues, function()
				local parent = Instance.new("Folder")
				local key = "Some Key"

				local firstElement = createElement("Frame")
				local secondElement = createElement("Frame", {
					Frob = 6,
				})

				local node = reconciler.createVirtualNode(firstElement, parent, key)
				RobloxRenderer.mountHostNode(reconciler, node)

				local success, message = pcall(RobloxRenderer.updateHostNode, reconciler, node, secondElement)
				assert(not success, "Expected call to fail")

				expect(message:find("Frob")).to.be.ok()
				expect(message:find("Frame")).to.be.ok()
				expect(message:find("RobloxRenderer%.spec")).to.be.ok()
			end)
		end)

		it("should delete instances when reconciling to nil children", function()
			local parent = Instance.new("Folder")
			local key = "Some Key"

			local element = createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
			}, {
				child = createElement("Frame"),
			})

			local node = reconciler.createVirtualNode(element, parent, key)

			RobloxRenderer.mountHostNode(reconciler, node)

			expect(#parent:GetChildren()).to.equal(1)

			local instance = parent:GetChildren()[1]
			expect(#instance:GetChildren()).to.equal(1)

			local newElement = createElement("Frame", {
				Size = UDim2.new(0.5, 0, 0.5, 0),
			})

			RobloxRenderer.updateHostNode(reconciler, node, newElement)
			expect(#instance:GetChildren()).to.equal(0)
		end)
	end)

	describe("unmountHostNode", function()
		it("should delete instances from the inside-out", function()
			local parent = Instance.new("Folder")
			local key = "Root"
			local element = createElement("Folder", nil, {
				Child = createElement("Folder", nil, {
					Grandchild = createElement("Folder"),
				}),
			})

			local node = reconciler.mountVirtualNode(element, parent, key)

			expect(#parent:GetChildren()).to.equal(1)

			local root = parent:GetChildren()[1]
			expect(#root:GetChildren()).to.equal(1)

			local child = root:GetChildren()[1]
			expect(#child:GetChildren()).to.equal(1)

			local grandchild = child:GetChildren()[1]

			RobloxRenderer.unmountHostNode(reconciler, node)

			expect(grandchild.Parent).to.equal(nil)
			expect(child.Parent).to.equal(nil)
			expect(root.Parent).to.equal(nil)
		end)

		it("should unsubscribe from any Bindings", function()
			local parent = Instance.new("Folder")
			local key = "Some Key"

			local binding, update = Binding.create(10)
			local element = createElement("IntValue", {
				Value = binding,
			})

			local node = reconciler.createVirtualNode(element, parent, key)

			RobloxRenderer.mountHostNode(reconciler, node)

			local instance = parent:GetChildren()[1]

			expect(instance.Value).to.equal(10)

			RobloxRenderer.unmountHostNode(reconciler, node)
			update(56)

			expect(instance.Value).to.equal(10)
		end)

		it("should clear Binding refs", function()
			local parent = Instance.new("Folder")
			local key = "Some Key"

			local ref = createRef()
			local element = createElement("Frame", {
				[Ref] = ref,
			})

			local node = reconciler.createVirtualNode(element, parent, key)

			RobloxRenderer.mountHostNode(reconciler, node)

			expect(ref.current).to.be.ok()

			RobloxRenderer.unmountHostNode(reconciler, node)

			expect(ref.current).never.to.be.ok()
		end)

		it("should call function refs with nil", function()
			local parent = Instance.new("Folder")
			local key = "Some Key"

			local spyRef = createSpy()
			local element = createElement("Frame", {
				[Ref] = spyRef.value,
			})

			local node = reconciler.createVirtualNode(element, parent, key)

			RobloxRenderer.mountHostNode(reconciler, node)

			expect(spyRef.callCount).to.equal(1)

			RobloxRenderer.unmountHostNode(reconciler, node)

			expect(spyRef.callCount).to.equal(2)
			spyRef:assertCalledWith(nil)
		end)
	end)

	describe("Portals", function()
		it("should create and destroy instances as children of `target`", function()
			local target = Instance.new("Folder")

			local function FunctionComponent(props)
				return createElement("IntValue", {
					Value = props.value,
				})
			end

			local element = createElement(Portal, {
				target = target,
			}, {
				folderOne = createElement("Folder"),
				folderTwo = createElement("Folder"),
				intValueOne = createElement(FunctionComponent, {
					value = 42,
				}),
			})
			local hostParent = nil
			local hostKey = "Some Key"
			local node = reconciler.mountVirtualNode(element, hostParent, hostKey)

			expect(#target:GetChildren()).to.equal(3)

			expect(target:FindFirstChild("folderOne")).to.be.ok()
			expect(target:FindFirstChild("folderTwo")).to.be.ok()
			expect(target:FindFirstChild("intValueOne")).to.be.ok()
			expect(target:FindFirstChild("intValueOne").Value).to.equal(42)

			reconciler.unmountVirtualNode(node)

			expect(#target:GetChildren()).to.equal(0)
		end)

		it("should pass prop updates through to children", function()
			local target = Instance.new("Folder")

			local firstElement = createElement(Portal, {
				target = target,
			}, {
				ChildValue = createElement("IntValue", {
					Value = 1,
				}),
			})

			local secondElement = createElement(Portal, {
				target = target,
			}, {
				ChildValue = createElement("IntValue", {
					Value = 2,
				}),
			})

			local hostParent = nil
			local hostKey = "A Host Key"
			local node = reconciler.mountVirtualNode(firstElement, hostParent, hostKey)

			expect(#target:GetChildren()).to.equal(1)

			local firstValue = target.ChildValue
			expect(firstValue.Value).to.equal(1)

			node = reconciler.updateVirtualNode(node, secondElement)

			expect(#target:GetChildren()).to.equal(1)

			local secondValue = target.ChildValue
			expect(firstValue).to.equal(secondValue)
			expect(secondValue.Value).to.equal(2)

			reconciler.unmountVirtualNode(node)

			expect(#target:GetChildren()).to.equal(0)
		end)

		it("should throw if `target` is nil", function()
			-- TODO: Relax this restriction?
			local element = createElement(Portal)
			local hostParent = nil
			local hostKey = "Keys for Everyone"

			expect(function()
				reconciler.mountVirtualNode(element, hostParent, hostKey)
			end).to.throw()
		end)

		it("should throw if `target` is not a Roblox instance", function()
			local element = createElement(Portal, {
				target = {},
			})
			local hostParent = nil
			local hostKey = "Unleash the keys!"

			expect(function()
				reconciler.mountVirtualNode(element, hostParent, hostKey)
			end).to.throw()
		end)

		it("should recreate instances if `target` changes in an update", function()
			local firstTarget = Instance.new("Folder")
			local secondTarget = Instance.new("Folder")

			local firstElement = createElement(Portal, {
				target = firstTarget,
			}, {
				ChildValue = createElement("IntValue", {
					Value = 1,
				}),
			})

			local secondElement = createElement(Portal, {
				target = secondTarget,
			}, {
				ChildValue = createElement("IntValue", {
					Value = 2,
				}),
			})

			local hostParent = nil
			local hostKey = "Some Key"
			local node = reconciler.mountVirtualNode(firstElement, hostParent, hostKey)

			expect(#firstTarget:GetChildren()).to.equal(1)
			expect(#secondTarget:GetChildren()).to.equal(0)

			local firstChild = firstTarget.ChildValue
			expect(firstChild.Value).to.equal(1)

			node = reconciler.updateVirtualNode(node, secondElement)

			expect(#firstTarget:GetChildren()).to.equal(0)
			expect(#secondTarget:GetChildren()).to.equal(1)

			local secondChild = secondTarget.ChildValue
			expect(secondChild.Value).to.equal(2)

			reconciler.unmountVirtualNode(node)

			expect(#firstTarget:GetChildren()).to.equal(0)
			expect(#secondTarget:GetChildren()).to.equal(0)
		end)
	end)

	describe("Fragments", function()
		it("should parent the fragment's elements into the fragment's parent", function()
			local hostParent = Instance.new("Folder")

			local fragment = createFragment({
				key = createElement("IntValue", {
					Value = 1,
				}),
				key2 = createElement("IntValue", {
					Value = 2,
				}),
			})

			local node = reconciler.mountVirtualNode(fragment, hostParent, "test")

			expect(hostParent:FindFirstChild("key")).to.be.ok()
			expect(hostParent.key.ClassName).to.equal("IntValue")
			expect(hostParent.key.Value).to.equal(1)

			expect(hostParent:FindFirstChild("key2")).to.be.ok()
			expect(hostParent.key2.ClassName).to.equal("IntValue")
			expect(hostParent.key2.Value).to.equal(2)

			reconciler.unmountVirtualNode(node)

			expect(#hostParent:GetChildren()).to.equal(0)
		end)

		it("should allow sibling fragment to have common keys", function()
			local hostParent = Instance.new("Folder")
			local hostKey = "Test"

			local function parent(_props)
				return createElement("IntValue", {}, {
					fragmentA = createFragment({
						key = createElement("StringValue", {
							Value = "A",
						}),
						key2 = createElement("StringValue", {
							Value = "B",
						}),
					}),
					fragmentB = createFragment({
						key = createElement("StringValue", {
							Value = "C",
						}),
						key2 = createElement("StringValue", {
							Value = "D",
						}),
					}),
				})
			end

			local node = reconciler.mountVirtualNode(createElement(parent), hostParent, hostKey)
			local parentChildren = hostParent[hostKey]:GetChildren()

			expect(#parentChildren).to.equal(4)

			local childValues = {}

			for _, child in pairs(parentChildren) do
				expect(child.ClassName).to.equal("StringValue")
				childValues[child.Value] = 1 + (childValues[child.Value] or 0)
			end

			-- check if the StringValues have not collided
			expect(childValues.A).to.equal(1)
			expect(childValues.B).to.equal(1)
			expect(childValues.C).to.equal(1)
			expect(childValues.D).to.equal(1)

			reconciler.unmountVirtualNode(node)

			expect(#hostParent:GetChildren()).to.equal(0)
		end)

		it("should render nested fragments", function()
			local hostParent = Instance.new("Folder")

			local fragment = createFragment({
				key = createFragment({
					TheValue = createElement("IntValue", {
						Value = 1,
					}),
					TheOtherValue = createElement("IntValue", {
						Value = 2,
					}),
				}),
			})

			local node = reconciler.mountVirtualNode(fragment, hostParent, "Test")

			expect(hostParent:FindFirstChild("TheValue")).to.be.ok()
			expect(hostParent.TheValue.ClassName).to.equal("IntValue")
			expect(hostParent.TheValue.Value).to.equal(1)

			expect(hostParent:FindFirstChild("TheOtherValue")).to.be.ok()
			expect(hostParent.TheOtherValue.ClassName).to.equal("IntValue")
			expect(hostParent.TheOtherValue.Value).to.equal(2)

			reconciler.unmountVirtualNode(node)

			expect(#hostParent:GetChildren()).to.equal(0)
		end)

		it("should not add any instances if the fragment is empty", function()
			local hostParent = Instance.new("Folder")

			local node = reconciler.mountVirtualNode(createFragment({}), hostParent, "test")

			expect(#hostParent:GetChildren()).to.equal(0)

			reconciler.unmountVirtualNode(node)

			expect(#hostParent:GetChildren()).to.equal(0)
		end)
	end)

	describe("Context", function()
		it("should pass context values through Roblox host nodes", function()
			local Consumer = Component:extend("Consumer")

			local capturedContext
			function Consumer:init()
				capturedContext = {
					hello = self:__getContext("hello"),
				}
			end

			function Consumer:render() end

			local element = createElement("Folder", nil, {
				Consumer = createElement(Consumer),
			})
			local hostParent = nil
			local hostKey = "Context Test"
			local context = {
				hello = "world",
			}
			local node = reconciler.mountVirtualNode(element, hostParent, hostKey, context)

			expect(capturedContext).never.to.equal(context)
			assertDeepEqual(capturedContext, context)

			reconciler.unmountVirtualNode(node)
		end)

		it("should pass context values through portal nodes", function()
			local target = Instance.new("Folder")

			local Provider = Component:extend("Provider")

			function Provider:init()
				self:__addContext("foo", "bar")
			end

			function Provider:render()
				return createElement("Folder", nil, self.props[Children])
			end

			local Consumer = Component:extend("Consumer")

			local capturedContext
			function Consumer:init()
				capturedContext = {
					foo = self:__getContext("foo"),
				}
			end

			function Consumer:render()
				return nil
			end

			local element = createElement(Provider, nil, {
				Portal = createElement(Portal, {
					target = target,
				}, {
					Consumer = createElement(Consumer),
				}),
			})
			local hostParent = nil
			local hostKey = "Some Key"
			reconciler.mountVirtualNode(element, hostParent, hostKey)

			assertDeepEqual(capturedContext, {
				foo = "bar",
			})
		end)
	end)

	describe("Legacy context", function()
		it("should pass context values through Roblox host nodes", function()
			local Consumer = Component:extend("Consumer")

			local capturedContext
			function Consumer:init()
				capturedContext = self._context
			end

			function Consumer:render() end

			local element = createElement("Folder", nil, {
				Consumer = createElement(Consumer),
			})
			local hostParent = nil
			local hostKey = "Context Test"
			local context = {
				hello = "world",
			}
			local node = reconciler.mountVirtualNode(element, hostParent, hostKey, nil, context)

			expect(capturedContext).never.to.equal(context)
			assertDeepEqual(capturedContext, context)

			reconciler.unmountVirtualNode(node)
		end)

		it("should pass context values through portal nodes", function()
			local target = Instance.new("Folder")

			local Provider = Component:extend("Provider")

			function Provider:init()
				self._context.foo = "bar"
			end

			function Provider:render()
				return createElement("Folder", nil, self.props[Children])
			end

			local Consumer = Component:extend("Consumer")

			local capturedContext
			function Consumer:init()
				capturedContext = self._context
			end

			function Consumer:render()
				return nil
			end

			local element = createElement(Provider, nil, {
				Portal = createElement(Portal, {
					target = target,
				}, {
					Consumer = createElement(Consumer),
				}),
			})
			local hostParent = nil
			local hostKey = "Some Key"
			reconciler.mountVirtualNode(element, hostParent, hostKey)

			assertDeepEqual(capturedContext, {
				foo = "bar",
			})
		end)
	end)

	describe("Integration Tests", function()
		local temporaryParent = nil
		beforeEach(function()
			temporaryParent = Instance.new("Folder")
			temporaryParent.Parent = ReplicatedStorage
		end)

		afterEach(function()
			temporaryParent:Destroy()
			temporaryParent = nil
		end)

		it("should not allow re-entrancy in updateChildren", function()
			local ChildComponent = Component:extend("ChildComponent")

			function ChildComponent:init()
				self:setState({
					firstTime = true,
				})
			end

			local childCoroutine

			function ChildComponent:render()
				if self.state.firstTime then
					return createElement("Frame")
				end

				return createElement("TextLabel")
			end

			function ChildComponent:didMount()
				childCoroutine = coroutine.create(function()
					self:setState({
						firstTime = false,
					})
				end)
			end

			local ParentComponent = Component:extend("ParentComponent")

			function ParentComponent:init()
				self:setState({
					count = 1,
				})

				self.childAdded = function()
					self:setState({
						count = self.state.count + 1,
					})
				end
			end

			function ParentComponent:render()
				return createElement("Frame", {
					[Event.ChildAdded] = self.childAdded,
				}, {
					ChildComponent = createElement(ChildComponent, {
						count = self.state.count,
					}),
				})
			end

			local parent = Instance.new("ScreenGui")
			parent.Parent = temporaryParent

			local tree = createElement(ParentComponent)

			local hostKey = "Some Key"
			local instance = reconciler.mountVirtualNode(tree, parent, hostKey)

			coroutine.resume(childCoroutine)

			expect(#parent:GetChildren()).to.equal(1)

			local frame = parent:GetChildren()[1]

			expect(#frame:GetChildren()).to.equal(1)

			reconciler.unmountVirtualNode(instance)
		end)

		it("should not allow re-entrancy in updateChildren even with callbacks", function()
			local LowestComponent = Component:extend("LowestComponent")

			function LowestComponent:render()
				return createElement("Frame")
			end

			function LowestComponent:didMount()
				self.props.onDidMountCallback()
			end

			local ChildComponent = Component:extend("ChildComponent")

			function ChildComponent:init()
				self:setState({
					firstTime = true,
				})
			end

			local childCoroutine

			function ChildComponent:render()
				if self.state.firstTime then
					return createElement("Frame")
				end

				return createElement(LowestComponent, {
					onDidMountCallback = self.props.onDidMountCallback,
				})
			end

			function ChildComponent:didMount()
				childCoroutine = coroutine.create(function()
					self:setState({
						firstTime = false,
					})
				end)
			end

			local ParentComponent = Component:extend("ParentComponent")

			local didMountCallbackCalled = 0

			function ParentComponent:init()
				self:setState({
					count = 1,
				})

				self.onDidMountCallback = function()
					didMountCallbackCalled = didMountCallbackCalled + 1
					if self.state.count < 5 then
						self:setState({
							count = self.state.count + 1,
						})
					end
				end
			end

			function ParentComponent:render()
				return createElement("Frame", {}, {
					ChildComponent = createElement(ChildComponent, {
						count = self.state.count,
						onDidMountCallback = self.onDidMountCallback,
					}),
				})
			end

			local parent = Instance.new("ScreenGui")
			parent.Parent = temporaryParent

			local tree = createElement(ParentComponent)

			local hostKey = "Some Key"
			local instance = reconciler.mountVirtualNode(tree, parent, hostKey)

			coroutine.resume(childCoroutine)

			expect(#parent:GetChildren()).to.equal(1)

			local frame = parent:GetChildren()[1]

			expect(#frame:GetChildren()).to.equal(1)

			-- In an ideal world, the didMount callback would probably be called only once. Since it is called by two different
			-- LowestComponent instantiations 2 is also acceptable though.
			expect(didMountCallbackCalled <= 2).to.equal(true)

			reconciler.unmountVirtualNode(instance)
		end)

		it("should never call unmount twice in the case of update children re-rentrancy", function()
			local unmountCounts = {}

			local function addUnmount(id)
				unmountCounts[id] = unmountCounts[id] + 1
			end

			local function addInit(id)
				unmountCounts[id] = 0
			end

			local LowestComponent = Component:extend("LowestComponent")
			function LowestComponent:init()
				addInit(tostring(self))
			end

			function LowestComponent:render()
				return createElement("Frame")
			end

			function LowestComponent:didMount()
				self.props.onDidMountCallback()
			end

			function LowestComponent:willUnmount()
				addUnmount(tostring(self))
			end

			local FirstComponent = Component:extend("FirstComponent")
			function FirstComponent:init()
				addInit(tostring(self))
			end

			function FirstComponent:render()
				return createElement("TextLabel")
			end

			function FirstComponent:willUnmount()
				addUnmount(tostring(self))
			end

			local ChildComponent = Component:extend("ChildComponent")

			function ChildComponent:init()
				addInit(tostring(self))

				self:setState({
					firstTime = true,
				})
			end

			local childCoroutine

			function ChildComponent:render()
				if self.state.firstTime then
					return createElement(FirstComponent)
				end

				return createElement(LowestComponent, {
					onDidMountCallback = self.props.onDidMountCallback,
				})
			end

			function ChildComponent:didMount()
				childCoroutine = coroutine.create(function()
					self:setState({
						firstTime = false,
					})
				end)
			end

			function ChildComponent:willUnmount()
				addUnmount(tostring(self))
			end

			local ParentComponent = Component:extend("ParentComponent")

			local didMountCallbackCalled = 0

			function ParentComponent:init()
				self:setState({
					count = 1,
				})

				self.onDidMountCallback = function()
					didMountCallbackCalled = didMountCallbackCalled + 1
					if self.state.count < 5 then
						self:setState({
							count = self.state.count + 1,
						})
					end
				end
			end

			function ParentComponent:render()
				return createElement("Frame", {}, {
					ChildComponent = createElement(ChildComponent, {
						count = self.state.count,
						onDidMountCallback = self.onDidMountCallback,
					}),
				})
			end

			local parent = Instance.new("ScreenGui")
			parent.Parent = temporaryParent

			local tree = createElement(ParentComponent)

			local hostKey = "Some Key"
			local instance = reconciler.mountVirtualNode(tree, parent, hostKey)

			coroutine.resume(childCoroutine)

			expect(#parent:GetChildren()).to.equal(1)

			local frame = parent:GetChildren()[1]

			expect(#frame:GetChildren()).to.equal(1)

			-- In an ideal world, the didMount callback would probably be called only once. Since it is called by two different
			-- LowestComponent instantiations 2 is also acceptable though.
			expect(didMountCallbackCalled <= 2).to.equal(true)

			reconciler.unmountVirtualNode(instance)

			for _, value in pairs(unmountCounts) do
				expect(value).to.equal(1)
			end
		end)

		it("should never unmount a node unnecesarily in the case of re-rentry", function()
			local LowestComponent = Component:extend("LowestComponent")
			function LowestComponent:render()
				return createElement("Frame")
			end

			function LowestComponent:didUpdate(prevProps, _prevState)
				if prevProps.firstTime and not self.props.firstTime then
					self.props.onChangedCallback()
				end
			end

			local ChildComponent = Component:extend("ChildComponent")

			function ChildComponent:init()
				self:setState({
					firstTime = true,
				})
			end

			local childCoroutine

			function ChildComponent:render()
				return createElement(LowestComponent, {
					firstTime = self.state.firstTime,
					onChangedCallback = self.props.onChangedCallback,
				})
			end

			function ChildComponent:didMount()
				childCoroutine = coroutine.create(function()
					self:setState({
						firstTime = false,
					})
				end)
			end

			local ParentComponent = Component:extend("ParentComponent")

			local onChangedCallbackCalled = 0

			function ParentComponent:init()
				self:setState({
					count = 1,
				})

				self.onChangedCallback = function()
					onChangedCallbackCalled = onChangedCallbackCalled + 1
					if self.state.count < 5 then
						self:setState({
							count = self.state.count + 1,
						})
					end
				end
			end

			function ParentComponent:render()
				return createElement("Frame", {}, {
					ChildComponent = createElement(ChildComponent, {
						count = self.state.count,
						onChangedCallback = self.onChangedCallback,
					}),
				})
			end

			local parent = Instance.new("ScreenGui")
			parent.Parent = temporaryParent

			local tree = createElement(ParentComponent)

			local hostKey = "Some Key"
			local instance = reconciler.mountVirtualNode(tree, parent, hostKey)

			coroutine.resume(childCoroutine)

			expect(#parent:GetChildren()).to.equal(1)

			local frame = parent:GetChildren()[1]

			expect(#frame:GetChildren()).to.equal(1)

			expect(onChangedCallbackCalled).to.equal(1)

			reconciler.unmountVirtualNode(instance)
		end)
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_dd162c2155e9d9c4c065e5baee5e7bda"] = _dd162c2155e9d9c4c065e5baee5e7bda
local _dd162c2155e9d9c4c065e5baee5e7bda = nil -- DEALLOCATE PLS :pray:

local _31d6aad2dd19400f71b1c093d35b483b = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_31d6aad2dd19400f71b1c093d35b483b.Name = "SingleEventManager"
_31d6aad2dd19400f71b1c093d35b483b.Properties.Source = [[ --\[\[
	A manager for a single host virtual node's connected events.
\]\]

local Logging = require(script.Parent.Logging)

local CHANGE_PREFIX = "Change."

local EventStatus = {
	-- No events are processed at all; they're silently discarded
	Disabled = "Disabled",

	-- Events are stored in a queue; listeners are invoked when the manager is resumed
	Suspended = "Suspended",

	-- Event listeners are invoked as the events fire
	Enabled = "Enabled",
}

local SingleEventManager = {}
SingleEventManager.__index = SingleEventManager

function SingleEventManager.new(instance)
	local self = setmetatable({
		-- The queue of suspended events
		_suspendedEventQueue = {},

		-- All the event connections being managed
		-- Events are indexed by a string key
		_connections = {},

		-- All the listeners being managed
		-- These are stored distinctly from the connections
		-- Connections can have their listeners replaced at runtime
		_listeners = {},

		-- The suspension status of the manager
		-- Managers start disabled and are "resumed" after the initial render
		_status = EventStatus.Disabled,

		-- If true, the manager is processing queued events right now.
		_isResuming = false,

		-- The Roblox instance the manager is managing
		_instance = instance,
	}, SingleEventManager)

	return self
end

function SingleEventManager:connectEvent(key, listener)
	self:_connect(key, self._instance[key], listener)
end

function SingleEventManager:connectPropertyChange(key, listener)
	local success, event = pcall(function()
		return self._instance:GetPropertyChangedSignal(key)
	end)

	if not success then
		error(("Cannot get changed signal on property %q: %s"):format(tostring(key), event), 0)
	end

	self:_connect(CHANGE_PREFIX .. key, event, listener)
end

function SingleEventManager:_connect(eventKey, event, listener)
	-- If the listener doesn't exist we can just disconnect the existing connection
	if listener == nil then
		if self._connections[eventKey] ~= nil then
			self._connections[eventKey]:Disconnect()
			self._connections[eventKey] = nil
		end

		self._listeners[eventKey] = nil
	else
		if self._connections[eventKey] == nil then
			self._connections[eventKey] = event:Connect(function(...)
				if self._status == EventStatus.Enabled then
					self._listeners[eventKey](self._instance, ...)
				elseif self._status == EventStatus.Suspended then
					-- Store this event invocation to be fired when resume is
					-- called.

					local argumentCount = select("#", ...)
					table.insert(self._suspendedEventQueue, { eventKey, argumentCount, ... })
				end
			end)
		end

		self._listeners[eventKey] = listener
	end
end

function SingleEventManager:suspend()
	self._status = EventStatus.Suspended
end

function SingleEventManager:resume()
	-- If we're already resuming events for this instance, trying to resume
	-- again would cause a disaster.
	if self._isResuming then
		return
	end

	self._isResuming = true

	local index = 1

	-- More events might be added to the queue when evaluating events, so we
	-- need to be careful in order to preserve correct evaluation order.
	while index <= #self._suspendedEventQueue do
		local eventInvocation = self._suspendedEventQueue[index]
		local listener = self._listeners[eventInvocation[1\]\]
		local argumentCount = eventInvocation[2]

		-- The event might have been disconnected since suspension started; in
		-- this case, we drop the event.
		if listener ~= nil then
			-- Wrap the listener in a coroutine to catch errors and handle
			-- yielding correctly.
			local listenerCo = coroutine.create(listener)
			local success, result = coroutine.resume(
				listenerCo,
				self._instance,
				unpack(eventInvocation, 3, 2 + argumentCount)
			)

			-- If the listener threw an error, we log it as a warning, since
			-- there's no way to write error text in Roblox Lua without killing
			-- our thread!
			if not success then
				Logging.warn("%s", result)
			end
		end

		index = index + 1
	end

	self._isResuming = false
	self._status = EventStatus.Enabled
	self._suspendedEventQueue = {}
end

return SingleEventManager ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_31d6aad2dd19400f71b1c093d35b483b"] = _31d6aad2dd19400f71b1c093d35b483b
local _31d6aad2dd19400f71b1c093d35b483b = nil -- DEALLOCATE PLS :pray:

local _cdb1e8a8e0eb8b61bf914c380b43b72f = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_cdb1e8a8e0eb8b61bf914c380b43b72f.Name = "SingleEventManager.spec"
_cdb1e8a8e0eb8b61bf914c380b43b72f.Properties.Source = [[ return function()
	local assertDeepEqual = require(script.Parent.assertDeepEqual)
	local createSpy = require(script.Parent.createSpy)
	local Logging = require(script.Parent.Logging)

	local SingleEventManager = require(script.Parent.SingleEventManager)

	describe("new", function()
		it("should create a SingleEventManager", function()
			local manager = SingleEventManager.new()

			expect(manager).to.be.ok()
		end)
	end)

	describe("connectEvent", function()
		it("should connect to events", function()
			local instance = Instance.new("BindableEvent")
			local manager = SingleEventManager.new(instance)
			local eventSpy = createSpy()

			manager:connectEvent("Event", eventSpy.value)
			manager:resume()

			instance:Fire("foo")
			expect(eventSpy.callCount).to.equal(1)
			eventSpy:assertCalledWith(instance, "foo")

			instance:Fire("bar")
			expect(eventSpy.callCount).to.equal(2)
			eventSpy:assertCalledWith(instance, "bar")

			manager:connectEvent("Event", nil)

			instance:Fire("baz")
			expect(eventSpy.callCount).to.equal(2)
		end)

		it("should drop events until resumed initially", function()
			local instance = Instance.new("BindableEvent")
			local manager = SingleEventManager.new(instance)
			local eventSpy = createSpy()

			manager:connectEvent("Event", eventSpy.value)

			instance:Fire("foo")
			expect(eventSpy.callCount).to.equal(0)

			manager:resume()

			instance:Fire("bar")
			expect(eventSpy.callCount).to.equal(1)
			eventSpy:assertCalledWith(instance, "bar")
		end)

		it("should invoke suspended events when resumed", function()
			local instance = Instance.new("BindableEvent")
			local manager = SingleEventManager.new(instance)
			local eventSpy = createSpy()

			manager:connectEvent("Event", eventSpy.value)
			manager:resume()

			instance:Fire("foo")
			expect(eventSpy.callCount).to.equal(1)
			eventSpy:assertCalledWith(instance, "foo")

			manager:suspend()

			instance:Fire("bar")
			expect(eventSpy.callCount).to.equal(1)

			manager:resume()
			expect(eventSpy.callCount).to.equal(2)
			eventSpy:assertCalledWith(instance, "bar")
		end)

		it("should invoke events triggered during resumption in the correct order", function()
			local instance = Instance.new("BindableEvent")
			local manager = SingleEventManager.new(instance)

			local recordedValues = {}
			local eventSpy = createSpy(function(_, value)
				table.insert(recordedValues, value)

				if value == 2 then
					instance:Fire(3)
				elseif value == 3 then
					instance:Fire(4)
				end
			end)

			manager:connectEvent("Event", eventSpy.value)
			manager:suspend()

			instance:Fire(1)
			instance:Fire(2)

			manager:resume()
			expect(eventSpy.callCount).to.equal(4)
			assertDeepEqual(recordedValues, { 1, 2, 3, 4 })
		end)

		it("should not invoke events fired during suspension but disconnected before resumption", function()
			local instance = Instance.new("BindableEvent")
			local manager = SingleEventManager.new(instance)
			local eventSpy = createSpy()

			manager:connectEvent("Event", eventSpy.value)
			manager:suspend()

			instance:Fire(1)

			manager:connectEvent("Event", nil)

			manager:resume()
			expect(eventSpy.callCount).to.equal(0)
		end)

		it("should not yield events through the SingleEventManager when resuming", function()
			local instance = Instance.new("BindableEvent")
			local manager = SingleEventManager.new(instance)

			manager:connectEvent("Event", function()
				coroutine.yield()
			end)

			manager:resume()

			local co = coroutine.create(function()
				instance:Fire(5)
			end)

			assert(coroutine.resume(co))
			expect(coroutine.status(co)).to.equal("dead")

			manager:suspend()
			instance:Fire(5)

			co = coroutine.create(function()
				manager:resume()
			end)

			assert(coroutine.resume(co))
			expect(coroutine.status(co)).to.equal("dead")
		end)

		it("should not throw errors through SingleEventManager when resuming", function()
			local errorText = "Error from SingleEventManager test"

			local instance = Instance.new("BindableEvent")
			local manager = SingleEventManager.new(instance)

			manager:connectEvent("Event", function()
				error(errorText)
			end)

			manager:resume()

			-- If we call instance:Fire() here, the error message will leak to
			-- the console since the thread's resumption will be handled by
			-- Roblox's scheduler.

			manager:suspend()
			instance:Fire(5)

			local logInfo = Logging.capture(function()
				manager:resume()
			end)

			expect(#logInfo.errors).to.equal(0)
			expect(#logInfo.warnings).to.equal(1)
			expect(#logInfo.infos).to.equal(0)

			expect(logInfo.warnings[1]:find(errorText)).to.be.ok()
		end)

		it("should not overflow with events if manager:resume() is invoked when resuming a suspended event", function()
			local instance = Instance.new("BindableEvent")
			local manager = SingleEventManager.new(instance)

			-- This connection emulates what happens if reconciliation is
			-- triggered again in response to reconciliation. Without
			-- appropriate guards, the inner resume() call will process the
			-- Fire(1) event again, causing a nasty stack overflow.
			local eventSpy = createSpy(function(_, value)
				if value == 1 then
					manager:suspend()
					instance:Fire(2)
					manager:resume()
				end
			end)

			manager:connectEvent("Event", eventSpy.value)

			manager:suspend()
			instance:Fire(1)
			manager:resume()

			expect(eventSpy.callCount).to.equal(2)
		end)
	end)

	describe("connectPropertyChange", function()
		-- Since property changes utilize the same mechanisms as other events,
		-- the tests here are slimmed down to reduce redundancy.

		it("should connect to property changes", function()
			local instance = Instance.new("Folder")
			local manager = SingleEventManager.new(instance)
			local eventSpy = createSpy()

			manager:connectPropertyChange("Name", eventSpy.value)
			manager:resume()

			instance.Name = "foo"
			expect(eventSpy.callCount).to.equal(1)
			eventSpy:assertCalledWith(instance)

			instance.Name = "bar"
			expect(eventSpy.callCount).to.equal(2)
			eventSpy:assertCalledWith(instance)

			manager:connectPropertyChange("Name")

			instance.Name = "baz"
			expect(eventSpy.callCount).to.equal(2)
		end)

		it("should throw an error if the property is invalid", function()
			local instance = Instance.new("Folder")
			local manager = SingleEventManager.new(instance)

			expect(function()
				manager:connectPropertyChange("foo", function() end)
			end).to.throw()
		end)
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_cdb1e8a8e0eb8b61bf914c380b43b72f"] = _cdb1e8a8e0eb8b61bf914c380b43b72f
local _cdb1e8a8e0eb8b61bf914c380b43b72f = nil -- DEALLOCATE PLS :pray:

local _5c47f6041cef40deaed79e5b455a06a1 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_5c47f6041cef40deaed79e5b455a06a1.Name = "Symbol"
_5c47f6041cef40deaed79e5b455a06a1.Properties.Source = [[ --!strict
--\[\[
	A 'Symbol' is an opaque marker type.

	Symbols have the type 'userdata', but when printed to the console, the name
	of the symbol is shown.
\]\]

local Symbol = {}

--\[\[
	Creates a Symbol with the given name.

	When printed or coerced to a string, the symbol will turn into the string
	given as its name.
\]\]
function Symbol.named(name)
	assert(type(name) == "string", "Symbols must be created using a string name!")

	local self = newproxy(true)

	local wrappedName = ("Symbol(%s)"):format(name)

	getmetatable(self).__tostring = function()
		return wrappedName
	end

	return self
end

return Symbol ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_5c47f6041cef40deaed79e5b455a06a1"] = _5c47f6041cef40deaed79e5b455a06a1
local _5c47f6041cef40deaed79e5b455a06a1 = nil -- DEALLOCATE PLS :pray:

local _90efe02cba8c8b93519ff67ebca5a13c = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_90efe02cba8c8b93519ff67ebca5a13c.Name = "Symbol.spec"
_90efe02cba8c8b93519ff67ebca5a13c.Properties.Source = [[ return function()
	local Symbol = require(script.Parent.Symbol)

	describe("named", function()
		it("should give an opaque object", function()
			local symbol = Symbol.named("foo")

			expect(symbol).to.be.a("userdata")
		end)

		it("should coerce to the given name", function()
			local symbol = Symbol.named("foo")

			local index = tostring(symbol):find("foo")
			expect(index).to.be.ok()
		end)

		it("should be unique when constructed", function()
			local symbolA = Symbol.named("abc")
			local symbolB = Symbol.named("abc")

			expect(symbolA).never.to.equal(symbolB)
		end)
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_90efe02cba8c8b93519ff67ebca5a13c"] = _90efe02cba8c8b93519ff67ebca5a13c
local _90efe02cba8c8b93519ff67ebca5a13c = nil -- DEALLOCATE PLS :pray:

local _9198dcd355c20beccf07109c51a5307c = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_9198dcd355c20beccf07109c51a5307c.Name = "Type"
_9198dcd355c20beccf07109c51a5307c.Properties.Source = [[ --\[\[
	Contains markers for annotating objects with types.

	To set the type of an object, use `Type` as a key and the actual marker as
	the value:

		local foo = {
			[Type] = Type.Foo,
		}
\]\]

local Symbol = require(script.Parent.Symbol)
local strict = require(script.Parent.strict)

local Type = newproxy(true)

local TypeInternal = {}

local function addType(name)
	TypeInternal[name] = Symbol.named("Roact" .. name)
end

addType("Binding")
addType("Element")
addType("HostChangeEvent")
addType("HostEvent")
addType("StatefulComponentClass")
addType("StatefulComponentInstance")
addType("VirtualNode")
addType("VirtualTree")

function TypeInternal.of(value)
	if typeof(value) ~= "table" then
		return nil
	end

	return value[Type]
end

getmetatable(Type).__index = TypeInternal

getmetatable(Type).__tostring = function()
	return "RoactType"
end

strict(TypeInternal, "Type")

return Type ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_9198dcd355c20beccf07109c51a5307c"] = _9198dcd355c20beccf07109c51a5307c
local _9198dcd355c20beccf07109c51a5307c = nil -- DEALLOCATE PLS :pray:

local _120a718af1e94d2523b1e17e3bbd64e8 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_120a718af1e94d2523b1e17e3bbd64e8.Name = "Type.spec"
_120a718af1e94d2523b1e17e3bbd64e8.Properties.Source = [[ return function()
	local Type = require(script.Parent.Type)

	describe("of", function()
		it("should return nil if the value is not a table", function()
			expect(Type.of(1)).to.equal(nil)
			expect(Type.of(true)).to.equal(nil)
			expect(Type.of("test")).to.equal(nil)
			expect(Type.of(print)).to.equal(nil)
		end)

		it("should return nil if the table has no type", function()
			expect(Type.of({})).to.equal(nil)
		end)

		it("should return the assigned type", function()
			local test = {
				[Type] = Type.Element,
			}

			expect(Type.of(test)).to.equal(Type.Element)
		end)
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_120a718af1e94d2523b1e17e3bbd64e8"] = _120a718af1e94d2523b1e17e3bbd64e8
local _120a718af1e94d2523b1e17e3bbd64e8 = nil -- DEALLOCATE PLS :pray:

local _ded215fb183cdbb74d74e1c00c6d1efe = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_ded215fb183cdbb74d74e1c00c6d1efe.Name = "assertDeepEqual"
_ded215fb183cdbb74d74e1c00c6d1efe.Properties.Source = [[ --!strict
--\[\[
	A utility used to assert that two objects are value-equal recursively. It
	outputs fairly nicely formatted messages to help diagnose why two objects
	would be different.

	This should only be used in tests.
\]\]

local function deepEqual(a: any, b: any): (boolean, string?)
	if typeof(a) ~= typeof(b) then
		local message = ("{1} is of type %s, but {2} is of type %s"):format(typeof(a), typeof(b))
		return false, message
	end

	if typeof(a) == "table" then
		local visitedKeys = {}

		for key, value in pairs(a) do
			visitedKeys[key] = true

			local success, innerMessage = deepEqual(value, b[key])
			if not success and innerMessage then
				local message = innerMessage
					:gsub("{1}", ("{1}[%s]"):format(tostring(key)))
					:gsub("{2}", ("{2}[%s]"):format(tostring(key)))

				return false, message
			end
		end

		for key, value in pairs(b) do
			if not visitedKeys[key] then
				local success, innerMessage = deepEqual(value, a[key])

				if not success and innerMessage then
					local message = innerMessage
						:gsub("{1}", ("{1}[%s]"):format(tostring(key)))
						:gsub("{2}", ("{2}[%s]"):format(tostring(key)))

					return false, message
				end
			end
		end

		return true, nil
	end

	if a == b then
		return true, nil
	end

	local message = "{1} ~= {2}"
	return false, message
end

local function assertDeepEqual(a, b)
	local success, innerMessageTemplate = deepEqual(a, b)

	if not success and innerMessageTemplate then
		local innerMessage = innerMessageTemplate:gsub("{1}", "first"):gsub("{2}", "second")

		local message = ("Values were not deep-equal.\n%s"):format(innerMessage)

		error(message, 2)
	end
end

return assertDeepEqual ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_ded215fb183cdbb74d74e1c00c6d1efe"] = _ded215fb183cdbb74d74e1c00c6d1efe
local _ded215fb183cdbb74d74e1c00c6d1efe = nil -- DEALLOCATE PLS :pray:

local _71cca29ffe76e8d6f5fddc3e65913a57 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_71cca29ffe76e8d6f5fddc3e65913a57.Name = "assertDeepEqual.spec"
_71cca29ffe76e8d6f5fddc3e65913a57.Properties.Source = [[ return function()
	local assertDeepEqual = require(script.Parent.assertDeepEqual)

	it("should fail with a message when args are not equal", function()
		local success, message = pcall(assertDeepEqual, 1, 2)

		expect(success).to.equal(false)
		expect(message:find("first ~= second")).to.be.ok()

		success, message = pcall(assertDeepEqual, {
			foo = 1,
		}, {
			foo = 2,
		})

		expect(success).to.equal(false)
		expect(message:find("first%[foo%] ~= second%[foo%]")).to.be.ok()
	end)

	it("should compare non-table values using standard '==' equality", function()
		assertDeepEqual(1, 1)
		assertDeepEqual("hello", "hello")
		assertDeepEqual(nil, nil)

		local someFunction = function() end
		local theSameFunction = someFunction

		assertDeepEqual(someFunction, theSameFunction)

		local A = {
			foo = someFunction,
		}
		local B = {
			foo = theSameFunction,
		}

		assertDeepEqual(A, B)
	end)

	it("should fail when types differ", function()
		local success, message = pcall(assertDeepEqual, 1, "1")

		expect(success).to.equal(false)
		expect(message:find("first is of type number, but second is of type string")).to.be.ok()
	end)

	it("should compare (and report about) nested tables", function()
		local A = {
			foo = "bar",
			nested = {
				foo = 1,
				bar = 2,
			},
		}
		local B = {
			foo = "bar",
			nested = {
				foo = 1,
				bar = 2,
			},
		}

		assertDeepEqual(A, B)

		local C = {
			foo = "bar",
			nested = {
				foo = 1,
				bar = 3,
			},
		}

		local success, message = pcall(assertDeepEqual, A, C)

		expect(success).to.equal(false)
		expect(message:find("first%[nested%]%[bar%] ~= second%[nested%]%[bar%]")).to.be.ok()
	end)

	it("should be commutative", function()
		local equalArgsA = {
			foo = "bar",
			hello = "world",
		}
		local equalArgsB = {
			foo = "bar",
			hello = "world",
		}

		assertDeepEqual(equalArgsA, equalArgsB)
		assertDeepEqual(equalArgsB, equalArgsA)

		local nonEqualArgs = {
			foo = "bar",
		}

		expect(function()
			assertDeepEqual(equalArgsA, nonEqualArgs)
		end).to.throw()
		expect(function()
			assertDeepEqual(nonEqualArgs, equalArgsA)
		end).to.throw()
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_71cca29ffe76e8d6f5fddc3e65913a57"] = _71cca29ffe76e8d6f5fddc3e65913a57
local _71cca29ffe76e8d6f5fddc3e65913a57 = nil -- DEALLOCATE PLS :pray:

local _4195d8e70e3e9303b9a11e62b650f2ac = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_4195d8e70e3e9303b9a11e62b650f2ac.Name = "assign"
_4195d8e70e3e9303b9a11e62b650f2ac.Properties.Source = [[ local None = require(script.Parent.None)

--\[\[
	Merges values from zero or more tables onto a target table. If a value is
	set to None, it will instead be removed from the table.

	This function is identical in functionality to JavaScript's Object.assign.
\]\]
local function assign(target, ...)
	for index = 1, select("#", ...) do
		local source = select(index, ...)

		if source ~= nil then
			for key, value in pairs(source) do
				if value == None then
					target[key] = nil
				else
					target[key] = value
				end
			end
		end
	end

	return target
end

return assign ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_4195d8e70e3e9303b9a11e62b650f2ac"] = _4195d8e70e3e9303b9a11e62b650f2ac
local _4195d8e70e3e9303b9a11e62b650f2ac = nil -- DEALLOCATE PLS :pray:

local _ae69c1f4b16e1e3cf8345a9d77e990d9 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_ae69c1f4b16e1e3cf8345a9d77e990d9.Name = "assign.spec"
_ae69c1f4b16e1e3cf8345a9d77e990d9.Properties.Source = [[ return function()
	local None = require(script.Parent.None)

	local assign = require(script.Parent.assign)

	it("should accept zero additional tables", function()
		local input = {}
		local result = assign(input)

		expect(input).to.equal(result)
	end)

	it("should merge multiple tables onto the given target table", function()
		local target: { a: number, b: number, c: number? } = {
			a = 5,
			b = 6,
		}

		local source1 = {
			b = 7,
			c = 8,
		}

		local source2 = {
			b = 8,
		}

		assign(target, source1, source2)

		expect(target.a).to.equal(5)
		expect(target.b).to.equal(source2.b)
		expect(target.c).to.equal(source1.c)
	end)

	it("should remove keys if specified as None", function()
		local target = {
			foo = 2,
			bar = 3,
		}

		local source = {
			foo = None,
		}

		assign(target, source)

		expect(target.foo).to.equal(nil)
		expect(target.bar).to.equal(3)
	end)

	it("should re-add keys if specified after None", function()
		local target = {
			foo = 2,
		}

		local source1 = {
			foo = None,
		}

		local source2 = {
			foo = 3,
		}

		assign(target, source1, source2)

		expect(target.foo).to.equal(source2.foo)
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_ae69c1f4b16e1e3cf8345a9d77e990d9"] = _ae69c1f4b16e1e3cf8345a9d77e990d9
local _ae69c1f4b16e1e3cf8345a9d77e990d9 = nil -- DEALLOCATE PLS :pray:

local _b02bf005f590a8566e56cefea9ec9cf8 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_b02bf005f590a8566e56cefea9ec9cf8.Name = "createContext"
_b02bf005f590a8566e56cefea9ec9cf8.Properties.Source = [[ local Symbol = require(script.Parent.Symbol)
local createFragment = require(script.Parent.createFragment)
local createSignal = require(script.Parent.createSignal)
local Children = require(script.Parent.PropMarkers.Children)
local Component = require(script.Parent.Component)

--\[\[
	Construct the value that is assigned to Roact's context storage.
\]\]
local function createContextEntry(currentValue)
	return {
		value = currentValue,
		onUpdate = createSignal(),
	}
end

local function createProvider(context)
	local Provider = Component:extend("Provider")

	function Provider:init(props)
		self.contextEntry = createContextEntry(props.value)
		self:__addContext(context.key, self.contextEntry)
	end

	function Provider:willUpdate(nextProps)
		-- If the provided value changed, immediately update the context entry.
		--
		-- During this update, any components that are reachable will receive
		-- this updated value at the same time as any props and state updates
		-- that are being applied.
		if nextProps.value ~= self.props.value then
			self.contextEntry.value = nextProps.value
		end
	end

	function Provider:didUpdate(prevProps)
		-- If the provided value changed, after we've updated every reachable
		-- component, fire a signal to update the rest.
		--
		-- This signal will notify all context consumers. It's expected that
		-- they will compare the last context value they updated with and only
		-- trigger an update on themselves if this value is different.
		--
		-- This codepath will generally only update consumer components that has
		-- a component implementing shouldUpdate between them and the provider.
		if prevProps.value ~= self.props.value then
			self.contextEntry.onUpdate:fire(self.props.value)
		end
	end

	function Provider:render()
		return createFragment(self.props[Children])
	end

	return Provider
end

local function createConsumer(context)
	local Consumer = Component:extend("Consumer")

	function Consumer.validateProps(props)
		if type(props.render) ~= "function" then
			return false, "Consumer expects a `render` function"
		else
			return true
		end
	end

	function Consumer:init(_props)
		-- This value may be nil, which indicates that our consumer is not a
		-- descendant of a provider for this context item.
		self.contextEntry = self:__getContext(context.key)
	end

	function Consumer:render()
		-- Render using the latest available for this context item.
		--
		-- We don't store this value in state in order to have more fine-grained
		-- control over our update behavior.
		local value
		if self.contextEntry ~= nil then
			value = self.contextEntry.value
		else
			value = context.defaultValue
		end

		return self.props.render(value)
	end

	function Consumer:didUpdate()
		-- Store the value that we most recently updated with.
		--
		-- This value is compared in the contextEntry onUpdate hook below.
		if self.contextEntry ~= nil then
			self.lastValue = self.contextEntry.value
		end
	end

	function Consumer:didMount()
		if self.contextEntry ~= nil then
			-- When onUpdate is fired, a new value has been made available in
			-- this context entry, but we may have already updated in the same
			-- update cycle.
			--
			-- To avoid sending a redundant update, we compare the new value
			-- with the last value that we updated with (set in didUpdate) and
			-- only update if they differ. This may happen when an update from a
			-- provider was blocked by an intermediate component that returned
			-- false from shouldUpdate.
			self.disconnect = self.contextEntry.onUpdate:subscribe(function(newValue)
				if newValue ~= self.lastValue then
					-- Trigger a dummy state update.
					self:setState({})
				end
			end)
		end
	end

	function Consumer:willUnmount()
		if self.disconnect ~= nil then
			self.disconnect()
			self.disconnect = nil
		end
	end

	return Consumer
end

local Context = {}
Context.__index = Context

function Context.new(defaultValue)
	return setmetatable({
		defaultValue = defaultValue,
		key = Symbol.named("ContextKey"),
	}, Context)
end

function Context:__tostring()
	return "RoactContext"
end

local function createContext(defaultValue)
	local context = Context.new(defaultValue)

	return {
		Provider = createProvider(context),
		Consumer = createConsumer(context),
	}
end

return createContext ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_b02bf005f590a8566e56cefea9ec9cf8"] = _b02bf005f590a8566e56cefea9ec9cf8
local _b02bf005f590a8566e56cefea9ec9cf8 = nil -- DEALLOCATE PLS :pray:

local _e90866210e56b77a64299f883a50c154 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_e90866210e56b77a64299f883a50c154.Name = "createContext.spec"
_e90866210e56b77a64299f883a50c154.Properties.Source = [[ return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local Component = require(script.Parent.Component)
	local NoopRenderer = require(script.Parent.NoopRenderer)
	local Children = require(script.Parent.PropMarkers.Children)
	local createContext = require(script.Parent.createContext)
	local createElement = require(script.Parent.createElement)
	local createFragment = require(script.Parent.createFragment)
	local createReconciler = require(script.Parent.createReconciler)
	local createSpy = require(script.Parent.createSpy)

	local noopReconciler = createReconciler(NoopRenderer)

	local RobloxRenderer = require(script.Parent.RobloxRenderer)
	local robloxReconciler = createReconciler(RobloxRenderer)

	it("should return a table", function()
		local context = createContext("Test")
		expect(context).to.be.ok()
		expect(type(context)).to.equal("table")
	end)

	it("should contain a Provider and a Consumer", function()
		local context = createContext("Test")
		expect(context.Provider).to.be.ok()
		expect(context.Consumer).to.be.ok()
	end)

	describe("Provider", function()
		it("should render its children", function()
			local context = createContext("Test")

			local Listener = createSpy(function()
				return nil
			end)

			local element = createElement(context.Provider, {
				value = "Test",
			}, {
				Listener = createElement(Listener.value),
			})

			local tree = noopReconciler.mountVirtualTree(element, nil, "Provide Tree")
			noopReconciler.unmountVirtualTree(tree)

			expect(Listener.callCount).to.equal(1)
		end)
	end)

	describe("Consumer", function()
		it("should expect a render function", function()
			local context = createContext("Test")
			local element = createElement(context.Consumer)

			expect(function()
				noopReconciler.mountVirtualTree(element, nil, "Provide Tree")
			end).to.throw()
		end)

		it("should return the default value if there is no Provider", function()
			local valueSpy = createSpy()
			local context = createContext("Test")

			local element = createElement(context.Consumer, {
				render = valueSpy.value,
			})

			local tree = noopReconciler.mountVirtualTree(element, nil, "Provide Tree")
			noopReconciler.unmountVirtualTree(tree)

			valueSpy:assertCalledWith("Test")
		end)

		it("should pass the value to the render function", function()
			local valueSpy = createSpy()
			local context = createContext("Test")

			local function Listener()
				return createElement(context.Consumer, {
					render = valueSpy.value,
				})
			end

			local element = createElement(context.Provider, {
				value = "NewTest",
			}, {
				Listener = createElement(Listener),
			})

			local tree = noopReconciler.mountVirtualTree(element, nil, "Provide Tree")
			noopReconciler.unmountVirtualTree(tree)

			valueSpy:assertCalledWith("NewTest")
		end)

		it("should update when the value updates", function()
			local valueSpy = createSpy()
			local context = createContext("Test")

			local function Listener()
				return createElement(context.Consumer, {
					render = valueSpy.value,
				})
			end

			local element = createElement(context.Provider, {
				value = "NewTest",
			}, {
				Listener = createElement(Listener),
			})

			local tree = noopReconciler.mountVirtualTree(element, nil, "Provide Tree")

			expect(valueSpy.callCount).to.equal(1)
			valueSpy:assertCalledWith("NewTest")

			noopReconciler.updateVirtualTree(
				tree,
				createElement(context.Provider, {
					value = "ThirdTest",
				}, {
					Listener = createElement(Listener),
				})
			)

			expect(valueSpy.callCount).to.equal(2)
			valueSpy:assertCalledWith("ThirdTest")

			noopReconciler.unmountVirtualTree(tree)
		end)

		--\[\[
			This test is the same as the one above, but with a component that
			always blocks updates in the middle. We expect behavior to be the
			same.
		\]\]
		it("should update when the value updates through an update blocking component", function()
			local valueSpy = createSpy()
			local context = createContext("Test")

			local UpdateBlocker = Component:extend("UpdateBlocker")

			function UpdateBlocker:render()
				return createFragment(self.props[Children])
			end

			function UpdateBlocker:shouldUpdate()
				return false
			end

			local function Listener()
				return createElement(context.Consumer, {
					render = valueSpy.value,
				})
			end

			local element = createElement(context.Provider, {
				value = "NewTest",
			}, {
				Blocker = createElement(UpdateBlocker, nil, {
					Listener = createElement(Listener),
				}),
			})

			local tree = noopReconciler.mountVirtualTree(element, nil, "Provide Tree")

			expect(valueSpy.callCount).to.equal(1)
			valueSpy:assertCalledWith("NewTest")

			noopReconciler.updateVirtualTree(
				tree,
				createElement(context.Provider, {
					value = "ThirdTest",
				}, {
					Blocker = createElement(UpdateBlocker, nil, {
						Listener = createElement(Listener),
					}),
				})
			)

			expect(valueSpy.callCount).to.equal(2)
			valueSpy:assertCalledWith("ThirdTest")

			noopReconciler.unmountVirtualTree(tree)
		end)

		it("should behave correctly when the default value is nil", function()
			local context = createContext(nil)

			local valueSpy = createSpy()
			local function Listener()
				return createElement(context.Consumer, {
					render = valueSpy.value,
				})
			end

			local tree = noopReconciler.mountVirtualTree(createElement(Listener), nil, "Provide Tree")
			expect(valueSpy.callCount).to.equal(1)
			valueSpy:assertCalledWith(nil)

			tree = noopReconciler.updateVirtualTree(tree, createElement(Listener))
			noopReconciler.unmountVirtualTree(tree)

			expect(valueSpy.callCount).to.equal(2)
			valueSpy:assertCalledWith(nil)
		end)
	end)

	describe("Update order", function()
		--\[\[
			This test ensures that there is no scenario where we can observe
			'update tearing' when props and context are updated at the same
			time.

			Update tearing is scenario where a single update is partially
			applied in multiple steps instead of atomically. This is observable
			by components and can lead to strange bugs or errors.

			This instance of update tearing happens when updating a prop and a
			context value in the same update. Image we represent our tree's
			state as the current prop and context versions. Our initial state
			is:

			(prop_1, context_1)

			The next state we would like to update to is:

			(prop_2, context_2)

			Under the bug reported in issue 259, Roact reaches three different
			states in sequence:

			1: (prop_1, context_1) - the initial state
			2: (prop_2, context_1) - woops!
			3: (prop_2, context_2) - correct end state

			In state 2, a user component was added that tried to access the
			current context value, which was not set at the time. This raised an
			error, because this state is not valid!

			The first proposed solution was to move the context update to happen
			before the props update. It is easy to show that this will still
			result in update tearing:

			1: (prop_1, context_1)
			2: (prop_1, context_2)
			3: (prop_2, context_2)

			Although the initial concern about newly added components observing
			old context values is fixed, there is still a state
			desynchronization between props and state.

			We would instead like the following update sequence:

			1: (prop_1, context_1)
			2: (prop_2, context_2)

			This test tries to ensure that is the case.

			The initial bug report is here:
			https://github.com/Roblox/roact/issues/259
		\]\]
		it("should update context at the same time as props", function()
			-- These values are used to make sure we reach both the first and
			-- second state combinations we want to visit.
			local observedA = false
			local observedB = false
			local updateCount = 0

			local context = createContext("default")

			local function Listener(props)
				return createElement(context.Consumer, {
					render = function(value)
						updateCount = updateCount + 1

						if value == "context_1" then
							expect(props.someProp).to.equal("prop_1")
							observedA = true
						elseif value == "context_2" then
							expect(props.someProp).to.equal("prop_2")
							observedB = true
						else
							error("Unexpected context value")
						end
					end,
				})
			end

			local element1 = createElement(context.Provider, {
				value = "context_1",
			}, {
				Child = createElement(Listener, {
					someProp = "prop_1",
				}),
			})

			local element2 = createElement(context.Provider, {
				value = "context_2",
			}, {
				Child = createElement(Listener, {
					someProp = "prop_2",
				}),
			})

			local tree = noopReconciler.mountVirtualTree(element1, nil, "UpdateObservationIsFun")
			noopReconciler.updateVirtualTree(tree, element2)

			expect(updateCount).to.equal(2)
			expect(observedA).to.equal(true)
			expect(observedB).to.equal(true)
		end)
	end)

	-- issue https://github.com/Roblox/roact/issues/319
	it("does not throw if willUnmount is called twice on a context consumer", function()
		local context = createContext({})

		local LowestComponent = Component:extend("LowestComponent")
		function LowestComponent:init() end

		function LowestComponent:render()
			return createElement("Frame")
		end

		function LowestComponent:didMount()
			self.props.onDidMountCallback()
		end

		local FirstComponent = Component:extend("FirstComponent")
		function FirstComponent:init() end

		function FirstComponent:render()
			return createElement(context.Consumer, {
				render = function()
					return createElement("TextLabel")
				end,
			})
		end

		local ChildComponent = Component:extend("ChildComponent")

		function ChildComponent:init()
			self:setState({ firstTime = true })
		end

		local childCallback

		function ChildComponent:render()
			if self.state.firstTime then
				return createElement(FirstComponent)
			end

			return createElement(LowestComponent, {
				onDidMountCallback = self.props.onDidMountCallback,
			})
		end

		function ChildComponent:didMount()
			childCallback = function()
				self:setState({ firstTime = false })
			end
		end

		local ParentComponent = Component:extend("ParentComponent")

		local didMountCallbackCalled = 0

		function ParentComponent:init()
			self:setState({ count = 1 })

			self.onDidMountCallback = function()
				didMountCallbackCalled = didMountCallbackCalled + 1
				if self.state.count < 5 then
					self:setState({ count = self.state.count + 1 })
				end
			end
		end

		function ParentComponent:render()
			return createElement("Frame", {}, {
				Provider = createElement(context.Provider, {
					value = {},
				}, {
					ChildComponent = createElement(ChildComponent, {
						count = self.state.count,
						onDidMountCallback = self.onDidMountCallback,
					}),
				}),
			})
		end

		local parent = Instance.new("ScreenGui")
		parent.Parent = ReplicatedStorage

		local hostKey = "Some Key"
		robloxReconciler.mountVirtualNode(createElement(ParentComponent), parent, hostKey)

		expect(function()
			-- calling setState on ChildComponent will trigger `willUnmount` multiple times
			childCallback()
		end).never.to.throw()
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_e90866210e56b77a64299f883a50c154"] = _e90866210e56b77a64299f883a50c154
local _e90866210e56b77a64299f883a50c154 = nil -- DEALLOCATE PLS :pray:

local _86c83949d451d79a693a3060179d6471 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_86c83949d451d79a693a3060179d6471.Name = "createElement"
_86c83949d451d79a693a3060179d6471.Properties.Source = [[ local Children = require(script.Parent.PropMarkers.Children)
local ElementKind = require(script.Parent.ElementKind)
local Logging = require(script.Parent.Logging)
local Type = require(script.Parent.Type)

local config = require(script.Parent.GlobalConfig).get()

local multipleChildrenMessage = \[\[
The prop `Roact.Children` was defined but was overridden by the third parameter to createElement!
This can happen when a component passes props through to a child element but also uses the `children` argument:

	Roact.createElement("Frame", passedProps, {
		child = ...
	})

Instead, consider using a utility function to merge tables of children together:

	local children = mergeTables(passedProps[Roact.Children], {
		child = ...
	})

	local fullProps = mergeTables(passedProps, {
		[Roact.Children] = children
	})

	Roact.createElement("Frame", fullProps)\]\]

--\[\[
	Creates a new element representing the given component.

	Elements are lightweight representations of what a component instance should
	look like.

	Children is a shorthand for specifying `Roact.Children` as a key inside
	props. If specified, the passed `props` table is mutated!
\]\]
local function createElement(component, props, children)
	if config.typeChecks then
		assert(component ~= nil, "`component` is required")
		assert(typeof(props) == "table" or props == nil, "`props` must be a table or nil")
		assert(typeof(children) == "table" or children == nil, "`children` must be a table or nil")
	end

	if props == nil then
		props = {}
	end

	if children ~= nil then
		if props[Children] ~= nil then
			Logging.warnOnce(multipleChildrenMessage)
		end

		props[Children] = children
	end

	local elementKind = ElementKind.fromComponent(component)

	local element = {
		[Type] = Type.Element,
		[ElementKind] = elementKind,
		component = component,
		props = props,
	}

	if config.elementTracing then
		-- We trim out the leading newline since there's no way to specify the
		-- trace level without also specifying a message.
		element.source = debug.traceback("", 2):sub(2)
	end

	return element
end

return createElement ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_86c83949d451d79a693a3060179d6471"] = _86c83949d451d79a693a3060179d6471
local _86c83949d451d79a693a3060179d6471 = nil -- DEALLOCATE PLS :pray:

local _547f8238a7c21f49a36481ce4186f636 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_547f8238a7c21f49a36481ce4186f636.Name = "createElement.spec"
_547f8238a7c21f49a36481ce4186f636.Properties.Source = [[ return function()
	local Component = require(script.Parent.Component)
	local ElementKind = require(script.Parent.ElementKind)
	local GlobalConfig = require(script.Parent.GlobalConfig)
	local Logging = require(script.Parent.Logging)
	local Type = require(script.Parent.Type)
	local Portal = require(script.Parent.Portal)
	local Children = require(script.Parent.PropMarkers.Children)

	local createElement = require(script.Parent.createElement)

	it("should create new primitive elements", function()
		local element = createElement("Frame")

		expect(element).to.be.ok()
		expect(Type.of(element)).to.equal(Type.Element)
		expect(ElementKind.of(element)).to.equal(ElementKind.Host)
	end)

	it("should create new functional elements", function()
		local element = createElement(function() end)

		expect(element).to.be.ok()
		expect(Type.of(element)).to.equal(Type.Element)
		expect(ElementKind.of(element)).to.equal(ElementKind.Function)
	end)

	it("should create new stateful components", function()
		local Foo = Component:extend("Foo")

		local element = createElement(Foo)

		expect(element).to.be.ok()
		expect(Type.of(element)).to.equal(Type.Element)
		expect(ElementKind.of(element)).to.equal(ElementKind.Stateful)
	end)

	it("should create new portal elements", function()
		local element = createElement(Portal)

		expect(element).to.be.ok()
		expect(Type.of(element)).to.equal(Type.Element)
		expect(ElementKind.of(element)).to.equal(ElementKind.Portal)
	end)

	it("should accept props", function()
		local element = createElement("StringValue", {
			Value = "Foo",
		})

		expect(element).to.be.ok()
		expect(element.props.Value).to.equal("Foo")
	end)

	it("should accept props and children", function()
		local child = createElement("IntValue")

		local element = createElement("StringValue", {
			Value = "Foo",
		}, {
			Child = child,
		})

		expect(element).to.be.ok()
		expect(element.props.Value).to.equal("Foo")
		expect(element.props[Children]).to.be.ok()
		expect(element.props[Children].Child).to.equal(child)
	end)

	it("should accept children with without props", function()
		local child = createElement("IntValue")

		local element = createElement("StringValue", nil, {
			Child = child,
		})

		expect(element).to.be.ok()
		expect(element.props[Children]).to.be.ok()
		expect(element.props[Children].Child).to.equal(child)
	end)

	it("should warn once if children is specified in two different ways", function()
		local logInfo = Logging.capture(function()
			-- Using a loop here to ensure that multiple occurrences of the same
			-- warning only cause output once.
			for _ = 1, 2 do
				createElement("Frame", {
					[Children] = {},
				}, {})
			end
		end)

		expect(#logInfo.warnings).to.equal(1)
		expect(logInfo.warnings[1]:find("createElement")).to.be.ok()
		expect(logInfo.warnings[1]:find("Children")).to.be.ok()
	end)

	it("should have a `source` member if elementTracing is set", function()
		local config = {
			elementTracing = true,
		}

		GlobalConfig.scoped(config, function()
			local element = createElement("StringValue")

			expect(element.source).to.be.a("string")
		end)
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_547f8238a7c21f49a36481ce4186f636"] = _547f8238a7c21f49a36481ce4186f636
local _547f8238a7c21f49a36481ce4186f636 = nil -- DEALLOCATE PLS :pray:

local _6b214cbc40c1485465587096d803658c = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_6b214cbc40c1485465587096d803658c.Name = "createFragment"
_6b214cbc40c1485465587096d803658c.Properties.Source = [[ local ElementKind = require(script.Parent.ElementKind)
local Type = require(script.Parent.Type)

local function createFragment(elements)
	return {
		[Type] = Type.Element,
		[ElementKind] = ElementKind.Fragment,
		elements = elements,
	}
end

return createFragment ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_6b214cbc40c1485465587096d803658c"] = _6b214cbc40c1485465587096d803658c
local _6b214cbc40c1485465587096d803658c = nil -- DEALLOCATE PLS :pray:

local _afeb03e7c341ddcd2076ee8e20ca8aa1 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_afeb03e7c341ddcd2076ee8e20ca8aa1.Name = "createFragment.spec"
_afeb03e7c341ddcd2076ee8e20ca8aa1.Properties.Source = [[ return function()
	local ElementKind = require(script.Parent.ElementKind)
	local Type = require(script.Parent.Type)

	local createFragment = require(script.Parent.createFragment)

	it("should create new primitive elements", function()
		local fragment = createFragment({})

		expect(fragment).to.be.ok()
		expect(Type.of(fragment)).to.equal(Type.Element)
		expect(ElementKind.of(fragment)).to.equal(ElementKind.Fragment)
	end)

	it("should accept children", function()
		local subFragment = createFragment({})
		local fragment = createFragment({ key = subFragment })

		expect(fragment.elements.key).to.equal(subFragment)
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_afeb03e7c341ddcd2076ee8e20ca8aa1"] = _afeb03e7c341ddcd2076ee8e20ca8aa1
local _afeb03e7c341ddcd2076ee8e20ca8aa1 = nil -- DEALLOCATE PLS :pray:

local _cf8178b3fb75bcbb1f6949c55a341c46 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_cf8178b3fb75bcbb1f6949c55a341c46.Name = "createReconciler"
_cf8178b3fb75bcbb1f6949c55a341c46.Properties.Source = [[ --!nonstrict
local Type = require(script.Parent.Type)
local ElementKind = require(script.Parent.ElementKind)
local ElementUtils = require(script.Parent.ElementUtils)
local Children = require(script.Parent.PropMarkers.Children)
local Symbol = require(script.Parent.Symbol)
local internalAssert = require(script.Parent.internalAssert)

local config = require(script.Parent.GlobalConfig).get()

local InternalData = Symbol.named("InternalData")

--\[\[
	The reconciler is the mechanism in Roact that constructs the virtual tree
	that later gets turned into concrete objects by the renderer.

	Roact's reconciler is constructed with the renderer as an argument, which
	enables switching to different renderers for different platforms or
	scenarios.

	When testing the reconciler itself, it's common to use `NoopRenderer` with
	spies replacing some methods. The default (and only) reconciler interface
	exposed by Roact right now uses `RobloxRenderer`.
\]\]
local function createReconciler(renderer)
	local reconciler
	local mountVirtualNode
	local updateVirtualNode
	local unmountVirtualNode

	--\[\[
		Unmount the given virtualNode, replacing it with a new node described by
		the given element.

		Preserves host properties, depth, and legacyContext from parent.
	\]\]
	local function replaceVirtualNode(virtualNode, newElement)
		local hostParent = virtualNode.hostParent
		local hostKey = virtualNode.hostKey
		local depth = virtualNode.depth
		local parent = virtualNode.parent

		-- If the node that is being replaced has modified context, we need to
		-- use the original *unmodified* context for the new node
		-- The `originalContext` field will be nil if the context was unchanged
		local context = virtualNode.originalContext or virtualNode.context
		local parentLegacyContext = virtualNode.parentLegacyContext

		-- If updating this node has caused a component higher up the tree to re-render
		-- and updateChildren to be re-entered then this node could already have been
		-- unmounted in the previous updateChildren pass.
		if not virtualNode.wasUnmounted then
			unmountVirtualNode(virtualNode)
		end
		local newNode = mountVirtualNode(newElement, hostParent, hostKey, context, parentLegacyContext)

		-- mountVirtualNode can return nil if the element is a boolean
		if newNode ~= nil then
			newNode.depth = depth
			newNode.parent = parent
		end

		return newNode
	end

	--\[\[
		Utility to update the children of a virtual node based on zero or more
		updated children given as elements.
	\]\]
	local function updateChildren(virtualNode, hostParent, newChildElements)
		if config.internalTypeChecks then
			internalAssert(Type.of(virtualNode) == Type.VirtualNode, "Expected arg #1 to be of type VirtualNode")
		end

		virtualNode.updateChildrenCount = virtualNode.updateChildrenCount + 1

		local currentUpdateChildrenCount = virtualNode.updateChildrenCount

		local removeKeys = {}

		-- Changed or removed children
		for childKey, childNode in pairs(virtualNode.children) do
			local newElement = ElementUtils.getElementByKey(newChildElements, childKey)
			local newNode = updateVirtualNode(childNode, newElement)

			-- If updating this node has caused a component higher up the tree to re-render
			-- and updateChildren to be re-entered for this virtualNode then
			-- this result is invalid and needs to be disgarded.
			if virtualNode.updateChildrenCount ~= currentUpdateChildrenCount then
				if newNode and newNode ~= virtualNode.children[childKey] then
					unmountVirtualNode(newNode)
				end
				return
			end

			if newNode ~= nil then
				virtualNode.children[childKey] = newNode
			else
				removeKeys[childKey] = true
			end
		end

		for childKey in pairs(removeKeys) do
			virtualNode.children[childKey] = nil
		end

		-- Added children
		for childKey, newElement in ElementUtils.iterateElements(newChildElements) do
			local concreteKey = childKey
			if childKey == ElementUtils.UseParentKey then
				concreteKey = virtualNode.hostKey
			end

			if virtualNode.children[childKey] == nil then
				local childNode = mountVirtualNode(
					newElement,
					hostParent,
					concreteKey,
					virtualNode.context,
					virtualNode.legacyContext
				)

				-- If updating this node has caused a component higher up the tree to re-render
				-- and updateChildren to be re-entered for this virtualNode then
				-- this result is invalid and needs to be discarded.
				if virtualNode.updateChildrenCount ~= currentUpdateChildrenCount then
					if childNode then
						unmountVirtualNode(childNode)
					end
					return
				end

				-- mountVirtualNode can return nil if the element is a boolean
				if childNode ~= nil then
					childNode.depth = virtualNode.depth + 1
					childNode.parent = virtualNode
					virtualNode.children[childKey] = childNode
				end
			end
		end
	end

	local function updateVirtualNodeWithChildren(virtualNode, hostParent, newChildElements)
		updateChildren(virtualNode, hostParent, newChildElements)
	end

	local function updateVirtualNodeWithRenderResult(virtualNode, hostParent, renderResult)
		if Type.of(renderResult) == Type.Element or renderResult == nil or typeof(renderResult) == "boolean" then
			updateChildren(virtualNode, hostParent, renderResult)
		else
			error(
				("%s\n%s"):format(
					"Component returned invalid children:",
					virtualNode.currentElement.source or "<enable element tracebacks>"
				),
				0
			)
		end
	end

	--\[\[
		Unmounts the given virtual node and releases any held resources.
	\]\]
	function unmountVirtualNode(virtualNode)
		if config.internalTypeChecks then
			internalAssert(Type.of(virtualNode) == Type.VirtualNode, "Expected arg #1 to be of type VirtualNode")
		end

		virtualNode.wasUnmounted = true

		local kind = ElementKind.of(virtualNode.currentElement)

		-- selene: allow(if_same_then_else)
		if kind == ElementKind.Host then
			renderer.unmountHostNode(reconciler, virtualNode)
		elseif kind == ElementKind.Function then
			for _, childNode in pairs(virtualNode.children) do
				unmountVirtualNode(childNode)
			end
		elseif kind == ElementKind.Stateful then
			virtualNode.instance:__unmount()
		elseif kind == ElementKind.Portal then
			for _, childNode in pairs(virtualNode.children) do
				unmountVirtualNode(childNode)
			end
		elseif kind == ElementKind.Fragment then
			for _, childNode in pairs(virtualNode.children) do
				unmountVirtualNode(childNode)
			end
		else
			error(("Unknown ElementKind %q"):format(tostring(kind)), 2)
		end
	end

	local function updateFunctionVirtualNode(virtualNode, newElement)
		local children = newElement.component(newElement.props)

		updateVirtualNodeWithRenderResult(virtualNode, virtualNode.hostParent, children)

		return virtualNode
	end

	local function updatePortalVirtualNode(virtualNode, newElement)
		local oldElement = virtualNode.currentElement
		local oldTargetHostParent = oldElement.props.target

		local targetHostParent = newElement.props.target

		assert(renderer.isHostObject(targetHostParent), "Expected target to be host object")

		if targetHostParent ~= oldTargetHostParent then
			return replaceVirtualNode(virtualNode, newElement)
		end

		local children = newElement.props[Children]

		updateVirtualNodeWithChildren(virtualNode, targetHostParent, children)

		return virtualNode
	end

	local function updateFragmentVirtualNode(virtualNode, newElement)
		updateVirtualNodeWithChildren(virtualNode, virtualNode.hostParent, newElement.elements)

		return virtualNode
	end

	--\[\[
		Update the given virtual node using a new element describing what it
		should transform into.

		`updateVirtualNode` will return a new virtual node that should replace
		the passed in virtual node. This is because a virtual node can be
		updated with an element referencing a different component!

		In that case, `updateVirtualNode` will unmount the input virtual node,
		mount a new virtual node, and return it in this case, while also issuing
		a warning to the user.
	\]\]
	function updateVirtualNode(virtualNode, newElement, newState: { [any]: any }?): { [any]: any }?
		if config.internalTypeChecks then
			internalAssert(Type.of(virtualNode) == Type.VirtualNode, "Expected arg #1 to be of type VirtualNode")
		end
		if config.typeChecks then
			assert(
				Type.of(newElement) == Type.Element or typeof(newElement) == "boolean" or newElement == nil,
				"Expected arg #2 to be of type Element, boolean, or nil"
			)
		end

		-- If nothing changed, we can skip this update
		if virtualNode.currentElement == newElement and newState == nil then
			return virtualNode
		end

		if typeof(newElement) == "boolean" or newElement == nil then
			unmountVirtualNode(virtualNode)
			return nil
		end

		if virtualNode.currentElement.component ~= newElement.component then
			return replaceVirtualNode(virtualNode, newElement)
		end

		local kind = ElementKind.of(newElement)

		local shouldContinueUpdate = true

		if kind == ElementKind.Host then
			virtualNode = renderer.updateHostNode(reconciler, virtualNode, newElement)
		elseif kind == ElementKind.Function then
			virtualNode = updateFunctionVirtualNode(virtualNode, newElement)
		elseif kind == ElementKind.Stateful then
			shouldContinueUpdate = virtualNode.instance:__update(newElement, newState)
		elseif kind == ElementKind.Portal then
			virtualNode = updatePortalVirtualNode(virtualNode, newElement)
		elseif kind == ElementKind.Fragment then
			virtualNode = updateFragmentVirtualNode(virtualNode, newElement)
		else
			error(("Unknown ElementKind %q"):format(tostring(kind)), 2)
		end

		-- Stateful components can abort updates via shouldUpdate. If that
		-- happens, we should stop doing stuff at this point.
		if not shouldContinueUpdate then
			return virtualNode
		end

		virtualNode.currentElement = newElement

		return virtualNode
	end

	--\[\[
		Constructs a new virtual node but not does mount it.
	\]\]
	local function createVirtualNode(element, hostParent, hostKey, context, legacyContext)
		if config.internalTypeChecks then
			internalAssert(
				renderer.isHostObject(hostParent) or hostParent == nil,
				"Expected arg #2 to be a host object"
			)
			internalAssert(typeof(context) == "table" or context == nil, "Expected arg #4 to be of type table or nil")
			internalAssert(
				typeof(legacyContext) == "table" or legacyContext == nil,
				"Expected arg #5 to be of type table or nil"
			)
		end
		if config.typeChecks then
			assert(hostKey ~= nil, "Expected arg #3 to be non-nil")
			assert(
				Type.of(element) == Type.Element or typeof(element) == "boolean",
				"Expected arg #1 to be of type Element or boolean"
			)
		end

		return {
			[Type] = Type.VirtualNode,
			currentElement = element,
			depth = 1,
			parent = nil,
			children = {},
			hostParent = hostParent,
			hostKey = hostKey,
			updateChildrenCount = 0,
			wasUnmounted = false,

			-- Legacy Context API
			-- A table of context values inherited from the parent node
			legacyContext = legacyContext,

			-- A saved copy of the parent context, used when replacing a node
			parentLegacyContext = legacyContext,

			-- Context API
			-- A table of context values inherited from the parent node
			context = context or {},

			-- A saved copy of the unmodified context; this will be updated when
			-- a component adds new context and used when a node is replaced
			originalContext = nil,
		}
	end

	local function mountFunctionVirtualNode(virtualNode)
		local element = virtualNode.currentElement

		local children = element.component(element.props)

		updateVirtualNodeWithRenderResult(virtualNode, virtualNode.hostParent, children)
	end

	local function mountPortalVirtualNode(virtualNode)
		local element = virtualNode.currentElement

		local targetHostParent = element.props.target
		local children = element.props[Children]

		assert(renderer.isHostObject(targetHostParent), "Expected target to be host object")

		updateVirtualNodeWithChildren(virtualNode, targetHostParent, children)
	end

	local function mountFragmentVirtualNode(virtualNode)
		local element = virtualNode.currentElement
		local children = element.elements

		updateVirtualNodeWithChildren(virtualNode, virtualNode.hostParent, children)
	end

	--\[\[
		Constructs a new virtual node and mounts it, but does not place it into
		the tree.
	\]\]
	function mountVirtualNode(element, hostParent, hostKey, context, legacyContext)
		if config.internalTypeChecks then
			internalAssert(
				renderer.isHostObject(hostParent) or hostParent == nil,
				"Expected arg #2 to be a host object"
			)
			internalAssert(
				typeof(legacyContext) == "table" or legacyContext == nil,
				"Expected arg #5 to be of type table or nil"
			)
		end
		if config.typeChecks then
			assert(hostKey ~= nil, "Expected arg #3 to be non-nil")
			assert(
				Type.of(element) == Type.Element or typeof(element) == "boolean",
				"Expected arg #1 to be of type Element or boolean"
			)
		end

		-- Boolean values render as nil to enable terse conditional rendering.
		if typeof(element) == "boolean" then
			return nil
		end

		local kind = ElementKind.of(element)

		local virtualNode = createVirtualNode(element, hostParent, hostKey, context, legacyContext)

		if kind == ElementKind.Host then
			renderer.mountHostNode(reconciler, virtualNode)
		elseif kind == ElementKind.Function then
			mountFunctionVirtualNode(virtualNode)
		elseif kind == ElementKind.Stateful then
			element.component:__mount(reconciler, virtualNode)
		elseif kind == ElementKind.Portal then
			mountPortalVirtualNode(virtualNode)
		elseif kind == ElementKind.Fragment then
			mountFragmentVirtualNode(virtualNode)
		else
			error(("Unknown ElementKind %q"):format(tostring(kind)), 2)
		end

		return virtualNode
	end

	--\[\[
		Constructs a new Roact virtual tree, constructs a root node for
		it, and mounts it.
	\]\]
	local function mountVirtualTree(element, hostParent, hostKey)
		if config.typeChecks then
			assert(Type.of(element) == Type.Element, "Expected arg #1 to be of type Element")
			assert(renderer.isHostObject(hostParent) or hostParent == nil, "Expected arg #2 to be a host object")
		end

		if hostKey == nil then
			hostKey = "RoactTree"
		end

		local tree = {
			[Type] = Type.VirtualTree,
			[InternalData] = {
				-- The root node of the tree, which starts into the hierarchy of
				-- Roact component instances.
				rootNode = nil,
				mounted = true,
			},
		}

		tree[InternalData].rootNode = mountVirtualNode(element, hostParent, hostKey)

		return tree
	end

	--\[\[
		Unmounts the virtual tree, freeing all of its resources.

		No further operations should be done on the tree after it's been
		unmounted, as indicated by its the `mounted` field.
	\]\]
	local function unmountVirtualTree(tree)
		local internalData = tree[InternalData]
		if config.typeChecks then
			assert(Type.of(tree) == Type.VirtualTree, "Expected arg #1 to be a Roact handle")
			assert(internalData.mounted, "Cannot unmounted a Roact tree that has already been unmounted")
		end

		internalData.mounted = false

		if internalData.rootNode ~= nil then
			unmountVirtualNode(internalData.rootNode)
		end
	end

	--\[\[
		Utility method for updating the root node of a virtual tree given a new
		element.
	\]\]
	local function updateVirtualTree(tree, newElement)
		local internalData = tree[InternalData]
		if config.typeChecks then
			assert(Type.of(tree) == Type.VirtualTree, "Expected arg #1 to be a Roact handle")
			assert(Type.of(newElement) == Type.Element, "Expected arg #2 to be a Roact Element")
		end

		internalData.rootNode = updateVirtualNode(internalData.rootNode, newElement)

		return tree
	end

	reconciler = {
		mountVirtualTree = mountVirtualTree,
		unmountVirtualTree = unmountVirtualTree,
		updateVirtualTree = updateVirtualTree,

		createVirtualNode = createVirtualNode,
		mountVirtualNode = mountVirtualNode,
		unmountVirtualNode = unmountVirtualNode,
		updateVirtualNode = updateVirtualNode,
		updateVirtualNodeWithChildren = updateVirtualNodeWithChildren,
		updateVirtualNodeWithRenderResult = updateVirtualNodeWithRenderResult,
	}

	return reconciler
end

return createReconciler ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_cf8178b3fb75bcbb1f6949c55a341c46"] = _cf8178b3fb75bcbb1f6949c55a341c46
local _cf8178b3fb75bcbb1f6949c55a341c46 = nil -- DEALLOCATE PLS :pray:

local _9e86ab653e1400f4bd812fe7daa4fedf = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_9e86ab653e1400f4bd812fe7daa4fedf.Name = "createReconciler.spec"
_9e86ab653e1400f4bd812fe7daa4fedf.Properties.Source = [[ return function()
	local assign = require(script.Parent.assign)
	local createElement = require(script.Parent.createElement)
	local createFragment = require(script.Parent.createFragment)
	local createSpy = require(script.Parent.createSpy)
	local NoopRenderer = require(script.Parent.NoopRenderer)
	local Type = require(script.Parent.Type)
	local ElementKind = require(script.Parent.ElementKind)

	local createReconciler = require(script.Parent.createReconciler)

	local noopReconciler = createReconciler(NoopRenderer)

	describe("tree operations", function()
		it("should mount and unmount", function()
			local tree = noopReconciler.mountVirtualTree(createElement("StringValue"))

			expect(tree).to.be.ok()

			noopReconciler.unmountVirtualTree(tree)
		end)

		it("should mount, update, and unmount", function()
			local tree = noopReconciler.mountVirtualTree(createElement("StringValue"))

			expect(tree).to.be.ok()

			noopReconciler.updateVirtualTree(tree, createElement("StringValue"))

			noopReconciler.unmountVirtualTree(tree)
		end)
	end)

	describe("booleans", function()
		it("should mount booleans as nil", function()
			local node = noopReconciler.mountVirtualNode(false, nil, "test")
			expect(node).to.equal(nil)
		end)

		it("should unmount nodes if they are updated to a boolean value", function()
			local node = noopReconciler.mountVirtualNode(createElement("StringValue"), nil, "test")

			expect(node).to.be.ok()

			node = noopReconciler.updateVirtualNode(node, true)

			expect(node).to.equal(nil)
		end)
	end)

	describe("invalid elements", function()
		it("should throw errors when attempting to mount invalid elements", function()
			-- These function components return values with incorrect types
			local returnsString = function()
				return "Hello"
			end
			local returnsNumber = function()
				return 1
			end
			local returnsFunction = function()
				return function() end
			end
			local returnsTable = function()
				return {}
			end

			local hostParent = nil
			local key = "Some Key"

			expect(function()
				noopReconciler.mountVirtualNode(createElement(returnsString), hostParent, key)
			end).to.throw()

			expect(function()
				noopReconciler.mountVirtualNode(createElement(returnsNumber), hostParent, key)
			end).to.throw()

			expect(function()
				noopReconciler.mountVirtualNode(createElement(returnsFunction), hostParent, key)
			end).to.throw()

			expect(function()
				noopReconciler.mountVirtualNode(createElement(returnsTable), hostParent, key)
			end).to.throw()
		end)
	end)

	describe("Host components", function()
		it("should invoke the renderer to mount host nodes", function()
			local mountHostNode = createSpy(NoopRenderer.mountHostNode)

			local renderer = assign({}, NoopRenderer, {
				mountHostNode = mountHostNode.value,
			})

			local reconciler = createReconciler(renderer)

			local element = createElement("StringValue")
			local hostParent = nil
			local key = "Some Key"
			local node = reconciler.mountVirtualNode(element, hostParent, key)

			expect(Type.of(node)).to.equal(Type.VirtualNode)

			expect(mountHostNode.callCount).to.equal(1)

			local values = mountHostNode:captureValues("reconciler", "node")

			expect(values.reconciler).to.equal(reconciler)
			expect(values.node).to.equal(node)
		end)

		it("should invoke the renderer to update host nodes", function()
			local updateHostNode = createSpy(NoopRenderer.updateHostNode)

			local renderer = assign({}, NoopRenderer, {
				mountHostNode = NoopRenderer.mountHostNode,
				updateHostNode = updateHostNode.value,
			})

			local reconciler = createReconciler(renderer)

			local element = createElement("StringValue")
			local hostParent = nil
			local key = "Key"
			local node = reconciler.mountVirtualNode(element, hostParent, key)

			expect(Type.of(node)).to.equal(Type.VirtualNode)

			local newElement = createElement("StringValue")
			local newNode = reconciler.updateVirtualNode(node, newElement)

			expect(newNode).to.equal(node)

			expect(updateHostNode.callCount).to.equal(1)

			local values = updateHostNode:captureValues("reconciler", "node", "newElement")

			expect(values.reconciler).to.equal(reconciler)
			expect(values.node).to.equal(node)
			expect(values.newElement).to.equal(newElement)
		end)

		it("should invoke the renderer to unmount host nodes", function()
			local unmountHostNode = createSpy(NoopRenderer.unmountHostNode)

			local renderer = assign({}, NoopRenderer, {
				mountHostNode = NoopRenderer.mountHostNode,
				unmountHostNode = unmountHostNode.value,
			})

			local reconciler = createReconciler(renderer)

			local element = createElement("StringValue")
			local hostParent = nil
			local key = "Key"
			local node = reconciler.mountVirtualNode(element, hostParent, key)

			expect(Type.of(node)).to.equal(Type.VirtualNode)

			reconciler.unmountVirtualNode(node)

			expect(unmountHostNode.callCount).to.equal(1)

			local values = unmountHostNode:captureValues("reconciler", "node")

			expect(values.reconciler).to.equal(reconciler)
			expect(values.node).to.equal(node)
		end)
	end)

	describe("Function components", function()
		it("should mount and unmount function components", function()
			local componentSpy = createSpy(function(_props)
				return nil
			end)

			local element = createElement(componentSpy.value, {
				someValue = 5,
			})
			local hostParent = nil
			local key = "A Key"
			local node = noopReconciler.mountVirtualNode(element, hostParent, key)

			expect(Type.of(node)).to.equal(Type.VirtualNode)

			expect(componentSpy.callCount).to.equal(1)

			local calledWith = componentSpy:captureValues("props")

			expect(calledWith.props).to.be.a("table")
			expect(calledWith.props.someValue).to.equal(5)

			noopReconciler.unmountVirtualNode(node)

			expect(componentSpy.callCount).to.equal(1)
		end)

		it("should mount single children of function components", function()
			local childComponentSpy = createSpy(function(_props)
				return nil
			end)

			local parentComponentSpy = createSpy(function(props)
				return createElement(childComponentSpy.value, {
					value = props.value + 1,
				})
			end)

			local element = createElement(parentComponentSpy.value, {
				value = 13,
			})
			local hostParent = nil
			local key = "A Key"
			local node = noopReconciler.mountVirtualNode(element, hostParent, key)

			expect(Type.of(node)).to.equal(Type.VirtualNode)

			expect(parentComponentSpy.callCount).to.equal(1)
			expect(childComponentSpy.callCount).to.equal(1)

			local parentCalledWith = parentComponentSpy:captureValues("props")
			local childCalledWith = childComponentSpy:captureValues("props")

			expect(parentCalledWith.props).to.be.a("table")
			expect(parentCalledWith.props.value).to.equal(13)

			expect(childCalledWith.props).to.be.a("table")
			expect(childCalledWith.props.value).to.equal(14)

			noopReconciler.unmountVirtualNode(node)

			expect(parentComponentSpy.callCount).to.equal(1)
			expect(childComponentSpy.callCount).to.equal(1)
		end)

		it("should mount fragments returned by function components", function()
			local childAComponentSpy = createSpy(function(_props)
				return nil
			end)

			local childBComponentSpy = createSpy(function(_props)
				return nil
			end)

			local parentComponentSpy = createSpy(function(props)
				return createFragment({
					A = createElement(childAComponentSpy.value, {
						value = props.value + 1,
					}),
					B = createElement(childBComponentSpy.value, {
						value = props.value + 5,
					}),
				})
			end)

			local element = createElement(parentComponentSpy.value, {
				value = 17,
			})
			local hostParent = nil
			local key = "A Key"
			local node = noopReconciler.mountVirtualNode(element, hostParent, key)

			expect(Type.of(node)).to.equal(Type.VirtualNode)

			expect(parentComponentSpy.callCount).to.equal(1)
			expect(childAComponentSpy.callCount).to.equal(1)
			expect(childBComponentSpy.callCount).to.equal(1)

			local parentCalledWith = parentComponentSpy:captureValues("props")
			local childACalledWith = childAComponentSpy:captureValues("props")
			local childBCalledWith = childBComponentSpy:captureValues("props")

			expect(parentCalledWith.props).to.be.a("table")
			expect(parentCalledWith.props.value).to.equal(17)

			expect(childACalledWith.props).to.be.a("table")
			expect(childACalledWith.props.value).to.equal(18)

			expect(childBCalledWith.props).to.be.a("table")
			expect(childBCalledWith.props.value).to.equal(22)

			noopReconciler.unmountVirtualNode(node)

			expect(parentComponentSpy.callCount).to.equal(1)
			expect(childAComponentSpy.callCount).to.equal(1)
			expect(childBComponentSpy.callCount).to.equal(1)
		end)
	end)

	describe("Fragments", function()
		it("should mount fragments", function()
			local fragment = createFragment({})
			local node = noopReconciler.mountVirtualNode(fragment, nil, "test")

			expect(node).to.be.ok()
			expect(ElementKind.of(node.currentElement)).to.equal(ElementKind.Fragment)
		end)

		it("should mount an empty fragment", function()
			local emptyFragment = createFragment({})
			local node = noopReconciler.mountVirtualNode(emptyFragment, nil, "test")

			expect(node).to.be.ok()

			local nextNode = next(node.children)
			expect(nextNode).to.never.be.ok()
		end)

		it("should mount all fragment's children", function()
			local childComponentSpy = createSpy(function(_props)
				return nil
			end)
			local elements = {}
			local totalElements = 5

			for i = 1, totalElements do
				elements["key" .. tostring(i)] = createElement(childComponentSpy.value, {})
			end

			local fragments = createFragment(elements)
			local node = noopReconciler.mountVirtualNode(fragments, nil, "test")

			expect(node).to.be.ok()
			expect(childComponentSpy.callCount).to.equal(totalElements)
		end)
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_9e86ab653e1400f4bd812fe7daa4fedf"] = _9e86ab653e1400f4bd812fe7daa4fedf
local _9e86ab653e1400f4bd812fe7daa4fedf = nil -- DEALLOCATE PLS :pray:

local _a3b2186d8808c2db7970866f32c6d7bb = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_a3b2186d8808c2db7970866f32c6d7bb.Name = "createReconcilerCompat"
_a3b2186d8808c2db7970866f32c6d7bb.Properties.Source = [[ --\[\[
	Contains deprecated methods from Reconciler. Broken out so that removing
	this shim is easy -- just delete this file and remove it from init.
\]\]

local Logging = require(script.Parent.Logging)

local reifyMessage = \[\[
Roact.reify has been renamed to Roact.mount and will be removed in a future release.
Check the call to Roact.reify at:
\]\]

local teardownMessage = \[\[
Roact.teardown has been renamed to Roact.unmount and will be removed in a future release.
Check the call to Roact.teardown at:
\]\]

local reconcileMessage = \[\[
Roact.reconcile has been renamed to Roact.update and will be removed in a future release.
Check the call to Roact.reconcile at:
\]\]

local function createReconcilerCompat(reconciler)
	local compat = {}

	function compat.reify(...)
		Logging.warnOnce(reifyMessage)

		return reconciler.mountVirtualTree(...)
	end

	function compat.teardown(...)
		Logging.warnOnce(teardownMessage)

		return reconciler.unmountVirtualTree(...)
	end

	function compat.reconcile(...)
		Logging.warnOnce(reconcileMessage)

		return reconciler.updateVirtualTree(...)
	end

	return compat
end

return createReconcilerCompat ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_a3b2186d8808c2db7970866f32c6d7bb"] = _a3b2186d8808c2db7970866f32c6d7bb
local _a3b2186d8808c2db7970866f32c6d7bb = nil -- DEALLOCATE PLS :pray:

local _e26e2c21f0d3e5ec2195fa7b7d4d8b12 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_e26e2c21f0d3e5ec2195fa7b7d4d8b12.Name = "createReconcilerCompat.spec"
_e26e2c21f0d3e5ec2195fa7b7d4d8b12.Properties.Source = [[ return function()
	local createElement = require(script.Parent.createElement)
	local createReconciler = require(script.Parent.createReconciler)
	local Logging = require(script.Parent.Logging)
	local NoopRenderer = require(script.Parent.NoopRenderer)

	local createReconcilerCompat = require(script.Parent.createReconcilerCompat)

	local noopReconciler = createReconciler(NoopRenderer)
	local compatReconciler = createReconcilerCompat(noopReconciler)

	it("reify should only warn once per call site", function()
		local logInfo = Logging.capture(function()
			-- We're using a loop so that we get the same stack trace and only one
			-- warning hopefully.
			for _ = 1, 2 do
				local handle = compatReconciler.reify(createElement("StringValue"))
				noopReconciler.unmountVirtualTree(handle)
			end
		end)

		expect(#logInfo.warnings).to.equal(1)
		expect(logInfo.warnings[1]:find("reify")).to.be.ok()

		logInfo = Logging.capture(function()
			-- This is a different call site, which should trigger another warning.
			local handle = compatReconciler.reify(createElement("StringValue"))
			noopReconciler.unmountVirtualTree(handle)
		end)

		expect(#logInfo.warnings).to.equal(1)
		expect(logInfo.warnings[1]:find("reify")).to.be.ok()
	end)

	it("teardown should only warn once per call site", function()
		local logInfo = Logging.capture(function()
			-- We're using a loop so that we get the same stack trace and only one
			-- warning hopefully.
			for _ = 1, 2 do
				local handle = noopReconciler.mountVirtualTree(createElement("StringValue"))
				compatReconciler.teardown(handle)
			end
		end)

		expect(#logInfo.warnings).to.equal(1)
		expect(logInfo.warnings[1]:find("teardown")).to.be.ok()

		logInfo = Logging.capture(function()
			-- This is a different call site, which should trigger another warning.
			local handle = noopReconciler.mountVirtualTree(createElement("StringValue"))
			compatReconciler.teardown(handle)
		end)

		expect(#logInfo.warnings).to.equal(1)
		expect(logInfo.warnings[1]:find("teardown")).to.be.ok()
	end)

	it("update should only warn once per call site", function()
		local logInfo = Logging.capture(function()
			-- We're using a loop so that we get the same stack trace and only one
			-- warning hopefully.
			for _ = 1, 2 do
				local handle = noopReconciler.mountVirtualTree(createElement("StringValue"))
				compatReconciler.reconcile(handle, createElement("StringValue"))
				noopReconciler.unmountVirtualTree(handle)
			end
		end)

		expect(#logInfo.warnings).to.equal(1)
		expect(logInfo.warnings[1]:find("reconcile")).to.be.ok()

		logInfo = Logging.capture(function()
			-- This is a different call site, which should trigger another warning.
			local handle = noopReconciler.mountVirtualTree(createElement("StringValue"))
			compatReconciler.reconcile(handle, createElement("StringValue"))
			noopReconciler.unmountVirtualTree(handle)
		end)

		expect(#logInfo.warnings).to.equal(1)
		expect(logInfo.warnings[1]:find("reconcile")).to.be.ok()
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_e26e2c21f0d3e5ec2195fa7b7d4d8b12"] = _e26e2c21f0d3e5ec2195fa7b7d4d8b12
local _e26e2c21f0d3e5ec2195fa7b7d4d8b12 = nil -- DEALLOCATE PLS :pray:

local _6a15dbcb6bc1cc5e6fe312c3e9118b8d = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_6a15dbcb6bc1cc5e6fe312c3e9118b8d.Name = "createRef"
_6a15dbcb6bc1cc5e6fe312c3e9118b8d.Properties.Source = [[ --\[\[
	A ref is nothing more than a binding with a special field 'current'
	that maps to the getValue method of the binding
\]\]
local Binding = require(script.Parent.Binding)

local function createRef()
	local binding, _ = Binding.create(nil)

	local ref = {}

	--\[\[
		A ref is just redirected to a binding via its metatable
	\]\]
	setmetatable(ref, {
		__index = function(_self, key)
			if key == "current" then
				return binding:getValue()
			else
				return binding[key]
			end
		end,
		__newindex = function(_self, key, value)
			if key == "current" then
				error("Cannot assign to the 'current' property of refs", 2)
			end

			binding[key] = value
		end,
		__tostring = function(_self)
			return ("RoactRef(%s)"):format(tostring(binding:getValue()))
		end,
	})

	return ref
end

return createRef ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_6a15dbcb6bc1cc5e6fe312c3e9118b8d"] = _6a15dbcb6bc1cc5e6fe312c3e9118b8d
local _6a15dbcb6bc1cc5e6fe312c3e9118b8d = nil -- DEALLOCATE PLS :pray:

local _3d86ea92f3a86c3902dba43a557cfc1a = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_3d86ea92f3a86c3902dba43a557cfc1a.Name = "createRef.spec"
_3d86ea92f3a86c3902dba43a557cfc1a.Properties.Source = [[ return function()
	local Binding = require(script.Parent.Binding)
	local Type = require(script.Parent.Type)

	local createRef = require(script.Parent.createRef)

	it("should create refs, which are specialized bindings", function()
		local ref = createRef()

		expect(Type.of(ref)).to.equal(Type.Binding)
		expect(ref.current).to.equal(nil)
	end)

	it("should have a 'current' field that is the same as the internal binding's value", function()
		local ref = createRef()

		expect(ref.current).to.equal(nil)

		Binding.update(ref, 10)
		expect(ref.current).to.equal(10)
	end)

	it("should support tostring on refs", function()
		local ref = createRef()

		expect(ref.current).to.equal(nil)
		expect(tostring(ref)).to.equal("RoactRef(nil)")

		Binding.update(ref, 10)
		expect(tostring(ref)).to.equal("RoactRef(10)")
	end)

	it("should not allow assignments to the 'current' field", function()
		local ref = createRef()

		expect(ref.current).to.equal(nil)

		Binding.update(ref, 99)
		expect(ref.current).to.equal(99)

		expect(function()
			ref.current = 77
		end).to.throw()

		expect(ref.current).to.equal(99)
	end)

	it("should return the same thing from getValue as its current field", function()
		local ref = createRef()
		Binding.update(ref, 10)

		expect(ref:getValue()).to.equal(10)
		expect(ref:getValue()).to.equal(ref.current)
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_3d86ea92f3a86c3902dba43a557cfc1a"] = _3d86ea92f3a86c3902dba43a557cfc1a
local _3d86ea92f3a86c3902dba43a557cfc1a = nil -- DEALLOCATE PLS :pray:

local _3474ab65c50e106bab1682321b69edbf = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_3474ab65c50e106bab1682321b69edbf.Name = "createSignal"
_3474ab65c50e106bab1682321b69edbf.Properties.Source = [[ --\[\[
	This is a simple signal implementation that has a dead-simple API.

		local signal = createSignal()

		local disconnect = signal:subscribe(function(foo)
			print("Cool foo:", foo)
		end)

		signal:fire("something")

		disconnect()
\]\]

local function createSignal()
	local connections = {}
	local suspendedConnections = {}
	local firing = false

	local function subscribe(_self, callback)
		assert(typeof(callback) == "function", "Can only subscribe to signals with a function.")

		local connection = {
			callback = callback,
			disconnected = false,
		}

		-- If the callback is already registered, don't add to the suspendedConnection. Otherwise, this will disable
		-- the existing one.
		if firing and not connections[callback] then
			suspendedConnections[callback] = connection
		end

		connections[callback] = connection

		local function disconnect()
			assert(not connection.disconnected, "Listeners can only be disconnected once.")

			connection.disconnected = true
			connections[callback] = nil
			suspendedConnections[callback] = nil
		end

		return disconnect
	end

	local function fire(_self, ...)
		firing = true
		for callback, connection in pairs(connections) do
			if not connection.disconnected and not suspendedConnections[callback] then
				callback(...)
			end
		end

		firing = false

		for callback, _ in pairs(suspendedConnections) do
			suspendedConnections[callback] = nil
		end
	end

	return {
		subscribe = subscribe,
		fire = fire,
	}
end

return createSignal ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_3474ab65c50e106bab1682321b69edbf"] = _3474ab65c50e106bab1682321b69edbf
local _3474ab65c50e106bab1682321b69edbf = nil -- DEALLOCATE PLS :pray:

local _f08fc55925657bf5c6449ea96ef18507 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_f08fc55925657bf5c6449ea96ef18507.Name = "createSignal.spec"
_f08fc55925657bf5c6449ea96ef18507.Properties.Source = [[ return function()
	local createSignal = require(script.Parent.createSignal)

	local createSpy = require(script.Parent.createSpy)

	it("should fire subscribers and disconnect them", function()
		local signal = createSignal()

		local spy = createSpy()
		local disconnect = signal:subscribe(spy.value)

		expect(spy.callCount).to.equal(0)

		local a = 1
		local b = {}
		local c = "hello"
		signal:fire(a, b, c)

		expect(spy.callCount).to.equal(1)
		spy:assertCalledWith(a, b, c)

		disconnect()

		signal:fire()

		expect(spy.callCount).to.equal(1)
	end)

	it("should handle multiple subscribers", function()
		local signal = createSignal()

		local spyA = createSpy()
		local spyB = createSpy()

		local disconnectA = signal:subscribe(spyA.value)
		local disconnectB = signal:subscribe(spyB.value)

		expect(spyA.callCount).to.equal(0)
		expect(spyB.callCount).to.equal(0)

		local a = {}
		local b = 67
		signal:fire(a, b)

		expect(spyA.callCount).to.equal(1)
		spyA:assertCalledWith(a, b)

		expect(spyB.callCount).to.equal(1)
		spyB:assertCalledWith(a, b)

		disconnectA()

		signal:fire(b, a)

		expect(spyA.callCount).to.equal(1)

		expect(spyB.callCount).to.equal(2)
		spyB:assertCalledWith(b, a)

		disconnectB()
	end)

	it("should stop firing a connection if disconnected mid-fire", function()
		local signal = createSignal()

		-- In this test, we'll connect two listeners that each try to disconnect
		-- the other. Because the order of listeners firing isn't defined, we
		-- have to be careful to handle either case.

		local disconnectA
		local disconnectB

		local spyA = createSpy(function()
			disconnectB()
		end)

		local spyB = createSpy(function()
			disconnectA()
		end)

		disconnectA = signal:subscribe(spyA.value)
		disconnectB = signal:subscribe(spyB.value)

		signal:fire()

		-- Exactly once listener should have been called.
		expect(spyA.callCount + spyB.callCount).to.equal(1)
	end)

	it("should allow adding listener in the middle of firing", function()
		local signal = createSignal()

		local disconnectA
		local spyA = createSpy()
		local listener = function(_a, _b)
			disconnectA = signal:subscribe(spyA.value)
		end

		local disconnectListener = signal:subscribe(listener)

		expect(spyA.callCount).to.equal(0)

		local a = {}
		local b = 67
		signal:fire(a, b)

		expect(spyA.callCount).to.equal(0)

		-- The new listener should be picked up in next fire.
		signal:fire(b, a)
		expect(spyA.callCount).to.equal(1)
		spyA:assertCalledWith(b, a)

		disconnectA()
		disconnectListener()

		signal:fire(a)

		expect(spyA.callCount).to.equal(1)
	end)

	it("should have one connection instance when add the same listener multiple times", function()
		local signal = createSignal()

		local spyA = createSpy()
		local disconnect1 = signal:subscribe(spyA.value)

		expect(spyA.callCount).to.equal(0)

		local a = {}
		local b = 67
		signal:fire(a, b)

		expect(spyA.callCount).to.equal(1)
		spyA:assertCalledWith(a, b)

		local disconnect2 = signal:subscribe(spyA.value)

		signal:fire(b, a)
		expect(spyA.callCount).to.equal(2)
		spyA:assertCalledWith(b, a)

		disconnect2()

		signal:fire(a)

		expect(spyA.callCount).to.equal(2)

		-- should have no effect.
		disconnect1()
		signal:fire(a)
		expect(spyA.callCount).to.equal(2)
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_f08fc55925657bf5c6449ea96ef18507"] = _f08fc55925657bf5c6449ea96ef18507
local _f08fc55925657bf5c6449ea96ef18507 = nil -- DEALLOCATE PLS :pray:

local _f8064f589de2997263ebd2503191a69c = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_f8064f589de2997263ebd2503191a69c.Name = "createSpy"
_f8064f589de2997263ebd2503191a69c.Properties.Source = [[ --\[\[
	A utility used to create a function spy that can be used to robustly test
	that functions are invoked the correct number of times and with the correct
	number of arguments.

	This should only be used in tests.
\]\]

local assertDeepEqual = require(script.Parent.assertDeepEqual)

local function createSpy(inner)
	local self = {}
	self.callCount = 0
	self.values = {}
	self.valuesLength = 0
	self.value = function(...)
		self.callCount = self.callCount + 1
		self.values = { ... }
		self.valuesLength = select("#", ...)

		if inner ~= nil then
			return inner(...)
		end
		return nil
	end

	self.assertCalledWith = function(_, ...)
		local len = select("#", ...)

		if self.valuesLength ~= len then
			error(("Expected %d arguments, but was called with %d arguments"):format(self.valuesLength, len), 2)
		end

		for i = 1, len do
			local expected = select(i, ...)

			assert(self.values[i] == expected, "value differs")
		end
	end

	self.assertCalledWithDeepEqual = function(_, ...)
		local len = select("#", ...)

		if self.valuesLength ~= len then
			error(("Expected %d arguments, but was called with %d arguments"):format(self.valuesLength, len), 2)
		end

		for i = 1, len do
			local expected = select(i, ...)

			assertDeepEqual(self.values[i], expected)
		end
	end

	self.captureValues = function(_, ...)
		local len = select("#", ...)
		local result = {}

		assert(self.valuesLength == len, "length of expected values differs from stored values")

		for i = 1, len do
			local key = select(i, ...)
			result[key] = self.values[i]
		end

		return result
	end

	setmetatable(self, {
		__index = function(_, key)
			error(("%q is not a valid member of spy"):format(key))
		end,
	})

	return self
end

return createSpy ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_f8064f589de2997263ebd2503191a69c"] = _f8064f589de2997263ebd2503191a69c
local _f8064f589de2997263ebd2503191a69c = nil -- DEALLOCATE PLS :pray:

local _1882b8d746580b1034031a280d0ae00a = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_1882b8d746580b1034031a280d0ae00a.Name = "createSpy.spec"
_1882b8d746580b1034031a280d0ae00a.Properties.Source = [[ return function()
	local createSpy = require(script.Parent.createSpy)

	describe("createSpy", function()
		it("should create spies", function()
			local spy = createSpy(function() end)

			expect(spy).to.be.ok()
		end)

		it("should throw if spies are indexed by an invalid key", function()
			local spy = createSpy(function() end)

			expect(function()
				return spy.test
			end).to.throw()
		end)
	end)

	describe("value", function()
		it("should increment callCount when called", function()
			local spy = createSpy(function() end)
			spy.value()

			expect(spy.callCount).to.equal(1)
		end)

		it("should store all values passed", function()
			local spy = createSpy(function() end)
			spy.value(1, true, "3")

			expect(spy.valuesLength).to.equal(3)
			expect(spy.values[1]).to.equal(1)
			expect(spy.values[2]).to.equal(true)
			expect(spy.values[3]).to.equal("3")
		end)

		it("should return the value of the inner function", function()
			local spy = createSpy(function()
				return true
			end)

			expect(spy.value()).to.equal(true)
		end)
	end)

	describe("assertCalledWith", function()
		it("should throw if the number of values differs", function()
			local spy = createSpy(function() end)
			spy.value(1, 2)

			expect(function()
				spy:assertCalledWith(1)
			end).to.throw()
		end)

		it("should throw if any value differs", function()
			local spy = createSpy(function() end)
			spy.value(1, 2)

			expect(function()
				spy:assertCalledWith(1, 3)
			end).to.throw()

			expect(function()
				spy:assertCalledWith(2, 3)
			end).to.throw()
		end)
	end)

	describe("captureValues", function()
		it("should throw if the number of values differs", function()
			local spy = createSpy(function() end)
			spy.value(1, 2)

			expect(function()
				spy:captureValues("a")
			end).to.throw()
		end)

		it("should capture all values in a table", function()
			local spy = createSpy(function() end)
			spy.value(1, 2)

			local captured = spy:captureValues("a", "b")
			expect(captured.a).to.equal(1)
			expect(captured.b).to.equal(2)
		end)
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_1882b8d746580b1034031a280d0ae00a"] = _1882b8d746580b1034031a280d0ae00a
local _1882b8d746580b1034031a280d0ae00a = nil -- DEALLOCATE PLS :pray:

local _155405e44633b62ab5bc338f6cf20ef9 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_155405e44633b62ab5bc338f6cf20ef9.Name = "forwardRef"
_155405e44633b62ab5bc338f6cf20ef9.Properties.Source = [[ local assign = require(script.Parent.assign)
local None = require(script.Parent.None)
local Ref = require(script.Parent.PropMarkers.Ref)

local config = require(script.Parent.GlobalConfig).get()

local excludeRef = {
	[Ref] = None,
}

--\[\[
	Allows forwarding of refs to underlying host components. Accepts a render
	callback which accepts props and a ref, and returns an element.
\]\]
local function forwardRef(render)
	if config.typeChecks then
		assert(typeof(render) == "function", "Expected arg #1 to be a function")
	end

	return function(props)
		local ref = props[Ref]
		local propsWithoutRef = assign({}, props, excludeRef)

		return render(propsWithoutRef, ref)
	end
end

return forwardRef ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_155405e44633b62ab5bc338f6cf20ef9"] = _155405e44633b62ab5bc338f6cf20ef9
local _155405e44633b62ab5bc338f6cf20ef9 = nil -- DEALLOCATE PLS :pray:

local _ba2ea279755f6edecea53960020cf21c = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_ba2ea279755f6edecea53960020cf21c.Name = "forwardRef.spec"
_ba2ea279755f6edecea53960020cf21c.Properties.Source = [[ -- Tests loosely adapted from those found at:
-- * https://github.com/facebook/react/blob/v17.0.1/packages/react/src/__tests__/forwardRef-test.js
-- * https://github.com/facebook/react/blob/v17.0.1/packages/react/src/__tests__/forwardRef-test.internal.js
return function()
	local assign = require(script.Parent.assign)
	local createElement = require(script.Parent.createElement)
	local createRef = require(script.Parent.createRef)
	local forwardRef = require(script.Parent.forwardRef)
	local createReconciler = require(script.Parent.createReconciler)
	local Component = require(script.Parent.Component)
	local GlobalConfig = require(script.Parent.GlobalConfig)
	local Ref = require(script.Parent.PropMarkers.Ref)

	local RobloxRenderer = require(script.Parent.RobloxRenderer)

	local reconciler = createReconciler(RobloxRenderer)

	it("should update refs when switching between children", function()
		local function FunctionComponent(props)
			local forwardedRef = props.forwardedRef
			local setRefOnDiv = props.setRefOnDiv
			-- deviation: clearer to express this way, since we don't have real
			-- ternaries
			local firstRef, secondRef
			if setRefOnDiv then
				firstRef = forwardedRef
			else
				secondRef = forwardedRef
			end
			return createElement("Frame", nil, {
				First = createElement("Frame", {
					[Ref] = firstRef,
				}, {
					Child = createElement("TextLabel", {
						Text = "First",
					}),
				}),
				Second = createElement("ScrollingFrame", {
					[Ref] = secondRef,
				}, {
					Child = createElement("TextLabel", {
						Text = "Second",
					}),
				}),
			})
		end

		local RefForwardingComponent = forwardRef(function(props, ref)
			return createElement(FunctionComponent, assign({}, props, { forwardedRef = ref }))
		end)

		local ref = createRef()

		local element = createElement(RefForwardingComponent, {
			[Ref] = ref,
			setRefOnDiv = true,
		})
		local tree = reconciler.mountVirtualTree(element, nil, "switch refs")
		expect(ref.current.ClassName).to.equal("Frame")
		reconciler.unmountVirtualTree(tree)

		element = createElement(RefForwardingComponent, {
			[Ref] = ref,
			setRefOnDiv = false,
		})
		tree = reconciler.mountVirtualTree(element, nil, "switch refs")
		expect(ref.current.ClassName).to.equal("ScrollingFrame")
		reconciler.unmountVirtualTree(tree)
	end)

	it("should support rendering nil", function()
		local RefForwardingComponent = forwardRef(function(_props, _ref)
			return nil
		end)

		local ref = createRef()

		local element = createElement(RefForwardingComponent, { [Ref] = ref })
		local tree = reconciler.mountVirtualTree(element, nil, "nil ref")
		expect(ref.current).to.equal(nil)
		reconciler.unmountVirtualTree(tree)
	end)

	it("should support rendering nil for multiple children", function()
		local RefForwardingComponent = forwardRef(function(_props, _ref)
			return nil
		end)

		local ref = createRef()

		local element = createElement("Frame", nil, {
			NoRef1 = createElement("Frame"),
			WithRef = createElement(RefForwardingComponent, { [Ref] = ref }),
			NoRef2 = createElement("Frame"),
		})
		local tree = reconciler.mountVirtualTree(element, nil, "multiple children nil ref")
		expect(ref.current).to.equal(nil)
		reconciler.unmountVirtualTree(tree)
	end)

	-- We could support this by having forwardRef return a stateful component,
	-- but it's likely not necessary
	itSKIP("should support defaultProps", function()
		local function FunctionComponent(props)
			local forwardedRef = props.forwardedRef
			local optional = props.optional
			local required = props.required
			return createElement("Frame", {
				[Ref] = forwardedRef,
			}, {
				OptionalChild = optional,
				RequiredChild = required,
			})
		end

		local RefForwardingComponent = forwardRef(function(props, ref)
			return createElement(
				FunctionComponent,
				assign({}, props, {
					forwardedRef = ref,
				})
			)
		end)
		RefForwardingComponent.defaultProps = {
			optional = createElement("TextLabel"),
		}

		local ref = createRef()

		local element = createElement(RefForwardingComponent, {
			[Ref] = ref,
			optional = createElement("Frame"),
			required = createElement("ScrollingFrame"),
		})

		local tree = reconciler.mountVirtualTree(element, nil, "with optional")

		expect(ref.current:FindFirstChild("OptionalChild").ClassName).to.equal("Frame")
		expect(ref.current:FindFirstChild("RequiredChild").ClassName).to.equal("ScrollingFrame")

		reconciler.unmountVirtualTree(tree)
		element = createElement(RefForwardingComponent, {
			[Ref] = ref,
			required = createElement("ScrollingFrame"),
		})
		tree = reconciler.mountVirtualTree(element, nil, "with default")

		expect(ref.current:FindFirstChild("OptionalChild").ClassName).to.equal("TextLabel")
		expect(ref.current:FindFirstChild("RequiredChild").ClassName).to.equal("ScrollingFrame")
		reconciler.unmountVirtualTree(tree)
	end)

	it("should error if not provided a callback when type checking is enabled", function()
		GlobalConfig.scoped({
			typeChecks = true,
		}, function()
			expect(function()
				forwardRef(nil)
			end).to.throw()
		end)

		GlobalConfig.scoped({
			typeChecks = true,
		}, function()
			expect(function()
				forwardRef("foo")
			end).to.throw()
		end)
	end)

	it("should work without a ref to be forwarded", function()
		local function Child()
			return nil
		end

		local function Wrapper(props)
			return createElement(Child, assign({}, props, { [Ref] = props.forwardedRef }))
		end

		local RefForwardingComponent = forwardRef(function(props, ref)
			return createElement(Wrapper, assign({}, props, { forwardedRef = ref }))
		end)

		local element = createElement(RefForwardingComponent, { value = 123 })
		local tree = reconciler.mountVirtualTree(element, nil, "nil ref")
		reconciler.unmountVirtualTree(tree)
	end)

	it("should forward a ref for a single child", function()
		local value
		local function Child(props)
			value = props.value
			return createElement("Frame", {
				[Ref] = props[Ref],
			})
		end

		local function Wrapper(props)
			return createElement(Child, assign({}, props, { [Ref] = props.forwardedRef }))
		end

		local RefForwardingComponent = forwardRef(function(props, ref)
			return createElement(Wrapper, assign({}, props, { forwardedRef = ref }))
		end)

		local ref = createRef()

		local element = createElement(RefForwardingComponent, { [Ref] = ref, value = 123 })
		local tree = reconciler.mountVirtualTree(element, nil, "single child ref")
		expect(value).to.equal(123)
		expect(ref.current.ClassName).to.equal("Frame")
		reconciler.unmountVirtualTree(tree)
	end)

	it("should forward a ref for multiple children", function()
		local function Child(props)
			return createElement("Frame", {
				[Ref] = props[Ref],
			})
		end

		local function Wrapper(props)
			return createElement(Child, assign({}, props, { [Ref] = props.forwardedRef }))
		end

		local RefForwardingComponent = forwardRef(function(props, ref)
			return createElement(Wrapper, assign({}, props, { forwardedRef = ref }))
		end)

		local ref = createRef()

		local element = createElement("Frame", nil, {
			NoRef1 = createElement("Frame"),
			WithRef = createElement(RefForwardingComponent, { [Ref] = ref }),
			NoRef2 = createElement("Frame"),
		})
		local tree = reconciler.mountVirtualTree(element, nil, "multi child ref")
		expect(ref.current.ClassName).to.equal("Frame")
		reconciler.unmountVirtualTree(tree)
	end)

	it("should maintain child instance and ref through updates", function()
		local value
		local function Child(props)
			value = props.value
			return createElement("Frame", {
				[Ref] = props[Ref],
			})
		end

		local function Wrapper(props)
			return createElement(Child, assign({}, props, { [Ref] = props.forwardedRef }))
		end

		local RefForwardingComponent = forwardRef(function(props, ref)
			return createElement(Wrapper, assign({}, props, { forwardedRef = ref }))
		end)

		local setRefCount = 0
		local refValue

		local setRef = function(r)
			setRefCount = setRefCount + 1
			refValue = r
		end

		local element = createElement(RefForwardingComponent, { [Ref] = setRef, value = 123 })
		local tree = reconciler.mountVirtualTree(element, nil, "maintains instance")

		expect(value).to.equal(123)
		expect(refValue.ClassName).to.equal("Frame")
		expect(setRefCount).to.equal(1)

		element = createElement(RefForwardingComponent, { [Ref] = setRef, value = 456 })
		tree = reconciler.updateVirtualTree(tree, element)

		expect(value).to.equal(456)
		expect(setRefCount).to.equal(1)
		reconciler.unmountVirtualTree(tree)
	end)

	it("should not re-run the render callback on a deep setState", function()
		local inst
		local renders = {}

		local Inner = Component:extend("Inner")
		function Inner:render()
			table.insert(renders, "Inner")
			inst = self
			return createElement("Frame", { [Ref] = self.props.forwardedRef })
		end

		local function Middle(props)
			table.insert(renders, "Middle")
			return createElement(Inner, props)
		end

		local Forward = forwardRef(function(props, ref)
			table.insert(renders, "Forward")
			return createElement(Middle, assign({}, props, { forwardedRef = ref }))
		end)

		local function App()
			table.insert(renders, "App")
			return createElement(Forward)
		end

		local tree = reconciler.mountVirtualTree(createElement(App), nil, "deep setState")
		expect(#renders).to.equal(4)
		expect(renders[1]).to.equal("App")
		expect(renders[2]).to.equal("Forward")
		expect(renders[3]).to.equal("Middle")
		expect(renders[4]).to.equal("Inner")

		renders = {}
		inst:setState({})
		expect(#renders).to.equal(1)
		expect(renders[1]).to.equal("Inner")
		reconciler.unmountVirtualTree(tree)
	end)

	it("should not include the ref in the forwarded props", function()
		local capturedProps
		local function CaptureProps(props)
			capturedProps = props
			return createElement("Frame", { [Ref] = props.forwardedRef })
		end

		local RefForwardingComponent = forwardRef(function(props, ref)
			return createElement(CaptureProps, assign({}, props, { forwardedRef = ref }))
		end)

		local ref = createRef()
		local element = createElement(RefForwardingComponent, {
			[Ref] = ref,
		})

		local tree = reconciler.mountVirtualTree(element, nil, "no ref in props")
		expect(capturedProps).to.be.ok()
		expect(capturedProps.forwardedRef).to.equal(ref)
		expect(capturedProps[Ref]).to.equal(nil)
		reconciler.unmountVirtualTree(tree)
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_ba2ea279755f6edecea53960020cf21c"] = _ba2ea279755f6edecea53960020cf21c
local _ba2ea279755f6edecea53960020cf21c = nil -- DEALLOCATE PLS :pray:

local _8996773ba67174a3e97a5acfa2644e24 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_8996773ba67174a3e97a5acfa2644e24.Name = "getDefaultInstanceProperty"
_8996773ba67174a3e97a5acfa2644e24.Properties.Source = [[ --\[\[
	Attempts to get the default value of a given property on a Roblox instance.

	This is used by the reconciler in cases where a prop was previously set on a
	primitive component, but is no longer present in a component's new props.

	Eventually, Roblox might provide a nicer API to query the default property
	of an object without constructing an instance of it.
\]\]

local Symbol = require(script.Parent.Symbol)

local Nil = Symbol.named("Nil")
local _cachedPropertyValues = {}

local function getDefaultInstanceProperty(className, propertyName)
	local classCache = _cachedPropertyValues[className]

	if classCache then
		local propValue = classCache[propertyName]

		-- We have to use a marker here, because Lua doesn't distinguish
		-- between 'nil' and 'not in a table'
		if propValue == Nil then
			return true, nil
		end

		if propValue ~= nil then
			return true, propValue
		end
	else
		classCache = {}
		_cachedPropertyValues[className] = classCache
	end

	local created = Instance.new(className)
	local ok, defaultValue = pcall(function()
		return created[propertyName]
	end)

	created:Destroy()

	if ok then
		if defaultValue == nil then
			classCache[propertyName] = Nil
		else
			classCache[propertyName] = defaultValue
		end
	end

	return ok, defaultValue
end

return getDefaultInstanceProperty ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_8996773ba67174a3e97a5acfa2644e24"] = _8996773ba67174a3e97a5acfa2644e24
local _8996773ba67174a3e97a5acfa2644e24 = nil -- DEALLOCATE PLS :pray:

local _871c2cd781ad4da89784a047358e5b5f = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_871c2cd781ad4da89784a047358e5b5f.Name = "getDefaultInstanceProperty.spec"
_871c2cd781ad4da89784a047358e5b5f.Properties.Source = [[ return function()
	local getDefaultInstanceProperty = require(script.Parent.getDefaultInstanceProperty)

	it("should get default name string values", function()
		local _, defaultName = getDefaultInstanceProperty("StringValue", "Name")

		expect(defaultName).to.equal("Value")
	end)

	it("should get default empty string values", function()
		local _, defaultValue = getDefaultInstanceProperty("StringValue", "Value")

		expect(defaultValue).to.equal("")
	end)

	it("should get default number values", function()
		local _, defaultValue = getDefaultInstanceProperty("IntValue", "Value")

		expect(defaultValue).to.equal(0)
	end)

	it("should get nil default values", function()
		local _, defaultValue = getDefaultInstanceProperty("ObjectValue", "Value")

		expect(defaultValue).to.equal(nil)
	end)

	it("should get bool default values", function()
		local _, defaultValue = getDefaultInstanceProperty("BoolValue", "Value")

		expect(defaultValue).to.equal(false)
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_871c2cd781ad4da89784a047358e5b5f"] = _871c2cd781ad4da89784a047358e5b5f
local _871c2cd781ad4da89784a047358e5b5f = nil -- DEALLOCATE PLS :pray:

local _acd8568bb3957a7c5b0c04617afe09fc = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_acd8568bb3957a7c5b0c04617afe09fc.Name = "init.spec"
_acd8568bb3957a7c5b0c04617afe09fc.Properties.Source = [[ return function()
	local Roact = require(script.Parent)

	it("should load with all public APIs", function()
		local publicApi = {
			createElement = "function",
			createFragment = "function",
			createRef = "function",
			forwardRef = "function",
			createBinding = "function",
			joinBindings = "function",
			mount = "function",
			unmount = "function",
			update = "function",
			oneChild = "function",
			setGlobalConfig = "function",
			createContext = "function",

			-- These functions are deprecated and throw warnings!
			reify = "function",
			teardown = "function",
			reconcile = "function",

			Component = true,
			PureComponent = true,
			Portal = true,
			Children = true,
			Event = true,
			Change = true,
			Ref = true,
			None = true,
			UNSTABLE = true,
		}

		expect(Roact).to.be.ok()

		for key, valueType in pairs(publicApi) do
			local success
			if typeof(valueType) == "string" then
				success = typeof(Roact[key]) == valueType
			else
				success = Roact[key] ~= nil
			end

			if not success then
				local existence = typeof(valueType) == "boolean" and "present" or "of type " .. tostring(valueType)
				local message = ("Expected public API member %q to be %s, but instead it was of type %s"):format(
					tostring(key),
					existence,
					typeof(Roact[key])
				)

				error(message)
			end
		end

		for key in pairs(Roact) do
			if publicApi[key] == nil then
				local message = ("Found unknown public API key %q!"):format(tostring(key))

				error(message)
			end
		end
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_acd8568bb3957a7c5b0c04617afe09fc"] = _acd8568bb3957a7c5b0c04617afe09fc
local _acd8568bb3957a7c5b0c04617afe09fc = nil -- DEALLOCATE PLS :pray:

local _88d20fbaab3c9276f4643618be136c2f = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_88d20fbaab3c9276f4643618be136c2f.Name = "internalAssert"
_88d20fbaab3c9276f4643618be136c2f.Properties.Source = [[ local function internalAssert(condition, message)
	if not condition then
		error(message .. " (This is probably a bug in Roact!)", 3)
	end
end

return internalAssert ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_88d20fbaab3c9276f4643618be136c2f"] = _88d20fbaab3c9276f4643618be136c2f
local _88d20fbaab3c9276f4643618be136c2f = nil -- DEALLOCATE PLS :pray:

local _9911962e476393fd2b2150fa74c109a9 = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_9911962e476393fd2b2150fa74c109a9.Name = "invalidSetStateMessages"
_9911962e476393fd2b2150fa74c109a9.Properties.Source = [[ --\[\[
	These messages are used by Component to help users diagnose when they're
	calling setState in inappropriate places.

	The indentation may seem odd, but it's necessary to avoid introducing extra
	whitespace into the error messages themselves.
\]\]
local ComponentLifecyclePhase = require(script.Parent.ComponentLifecyclePhase)

local invalidSetStateMessages = {}

invalidSetStateMessages[ComponentLifecyclePhase.WillUpdate] = \[\[
setState cannot be used in the willUpdate lifecycle method.
Consider using the didUpdate method instead, or using getDerivedStateFromProps.

Check the definition of willUpdate in the component %q.\]\]

invalidSetStateMessages[ComponentLifecyclePhase.ShouldUpdate] = \[\[
setState cannot be used in the shouldUpdate lifecycle method.
shouldUpdate must be a pure function that only depends on props and state.

Check the definition of shouldUpdate in the component %q.\]\]

invalidSetStateMessages[ComponentLifecyclePhase.Render] = \[\[
setState cannot be used in the render method.
render must be a pure function that only depends on props and state.

Check the definition of render in the component %q.\]\]

invalidSetStateMessages["default"] = \[\[
setState can not be used in the current situation, because Roact doesn't know
which part of the lifecycle this component is in.

This is a bug in Roact.
It was triggered by the component %q.
\]\]

return invalidSetStateMessages ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_9911962e476393fd2b2150fa74c109a9"] = _9911962e476393fd2b2150fa74c109a9
local _9911962e476393fd2b2150fa74c109a9 = nil -- DEALLOCATE PLS :pray:

local _48807eafb50148aeff1ec6655601676d = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_48807eafb50148aeff1ec6655601676d.Name = "oneChild"
_48807eafb50148aeff1ec6655601676d.Properties.Source = [[ --\[\[
	Retrieves at most one child from the children passed to a component.

	If passed nil or an empty table, will return nil.

	Throws an error if passed more than one child.
\]\]
local function oneChild(children)
	if not children then
		return nil
	end

	local key, child = next(children)

	if not child then
		return nil
	end

	local after = next(children, key)

	if after then
		error("Expected at most child, had more than one child.", 2)
	end

	return child
end

return oneChild ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_48807eafb50148aeff1ec6655601676d"] = _48807eafb50148aeff1ec6655601676d
local _48807eafb50148aeff1ec6655601676d = nil -- DEALLOCATE PLS :pray:

local _6157c58296a9aa7f885ca5ccac554e9d = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_6157c58296a9aa7f885ca5ccac554e9d.Name = "oneChild.spec"
_6157c58296a9aa7f885ca5ccac554e9d.Properties.Source = [[ return function()
	local createElement = require(script.Parent.createElement)

	local oneChild = require(script.Parent.oneChild)

	it("should get zero children from a table", function()
		local children = {}

		expect(oneChild(children)).to.equal(nil)
	end)

	it("should get exactly one child", function()
		local child = createElement("Frame")
		local children = {
			foo = child,
		}

		expect(oneChild(children)).to.equal(child)
	end)

	it("should error with more than one child", function()
		local children = {
			a = createElement("Frame"),
			b = createElement("Frame"),
		}

		expect(function()
			oneChild(children)
		end).to.throw()
	end)

	it("should handle being passed nil", function()
		expect(oneChild(nil)).to.equal(nil)
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_6157c58296a9aa7f885ca5ccac554e9d"] = _6157c58296a9aa7f885ca5ccac554e9d
local _6157c58296a9aa7f885ca5ccac554e9d = nil -- DEALLOCATE PLS :pray:

local _b916994bccf4f48955ab8dc80bf74c0d = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_b916994bccf4f48955ab8dc80bf74c0d.Name = "strict"
_b916994bccf4f48955ab8dc80bf74c0d.Properties.Source = [[ --!strict
local function strict(t: { [any]: any }, name: string?)
	-- FIXME Luau: Need to define a new variable since reassigning `name = ...`
	-- doesn't narrow the type
	local newName = name or tostring(t)

	return setmetatable(t, {
		__index = function(_self, key)
			local message = ("%q (%s) is not a valid member of %s"):format(tostring(key), typeof(key), newName)

			error(message, 2)
		end,

		__newindex = function(_self, key, _value)
			local message = ("%q (%s) is not a valid member of %s"):format(tostring(key), typeof(key), newName)

			error(message, 2)
		end,
	})
end

return strict ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_b916994bccf4f48955ab8dc80bf74c0d"] = _b916994bccf4f48955ab8dc80bf74c0d
local _b916994bccf4f48955ab8dc80bf74c0d = nil -- DEALLOCATE PLS :pray:

local _596ba04e7281c53ab108f4023cbe7f0d = { ClassName = "ModuleScript", Children = {}, Properties = {} }
_596ba04e7281c53ab108f4023cbe7f0d.Name = "strict.spec"
_596ba04e7281c53ab108f4023cbe7f0d.Properties.Source = [[ return function()
	local strict = require(script.Parent.strict)

	it("should error when getting a nonexistent key", function()
		local t = strict({
			a = 1,
			b = 2,
		})

		expect(function()
			return t.c
		end).to.throw()
	end)

	it("should error when setting a nonexistent key", function()
		local t = strict({
			a = 1,
			b = 2,
		})

		expect(function()
			t.c = 3
		end).to.throw()
	end)
end ]]
_4939180de2039ab164a0b6fd3ff1aed2.Children["_596ba04e7281c53ab108f4023cbe7f0d"] = _596ba04e7281c53ab108f4023cbe7f0d
local _596ba04e7281c53ab108f4023cbe7f0d = nil -- DEALLOCATE PLS :pray:
getfenv(0).rootTree = _9df0b325193e84994e6b9cc5ae584d22
getfenv(0).rootReferent = "_9df0b325193e84994e6b9cc5ae584d22"
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