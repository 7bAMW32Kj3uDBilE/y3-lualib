---abstract<br>
---@class NPBehave.Task.Task
---@overload fun(name: string): NPBehave.Task.Task
local Task = Class('NPBehave.Task.Task')

local superName = 'NPBehave.Node'
---@class NPBehave.Task.Task: NPBehave.Node
Extends('NPBehave.Task.Task', superName, function(self, super, ...)
    super(...)
end)

---@param name string
---@return self
function Task:__init(name)
    return self
end


return Task