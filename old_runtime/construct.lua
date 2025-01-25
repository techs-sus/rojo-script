-- This is not an actual runtime, just to be included in lua_sandbox

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
