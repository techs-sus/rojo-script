# Stages

Scripts refers to spawned scripts (by NS and NLS), and not the main scripts we are worried about. NLS script security will be based on remotes.

NLS:
```lua
local tree = ...
local createInstanceFromTree = ...

local fake = createInstanceFromTree(...)
script = fake
```

1. Scripts are not secure
2. Scripts are kinda secure &
3. Scripts are secure, do not retain vanilla behavior, and do not have rt.require patches
4. Scripts are very secure, retain vanilla behavior, and have requires (goal)
5. Scripts are secure and act like in studio

# Status

We are currently on stage 3. This is due to the fact that we need to implement rt.require and sandboxing. We need to sandbox fake scripts to allow for better developer experience, and so that developers can parent Instances to `script`.  