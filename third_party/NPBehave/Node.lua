---@class NPBehave.Node: Class.Base `abstract`, 不应该直接实例化, 请使用子类<br>
---@field protected currentState NPBehave.Enum.NodeState
---@field CurrentState NPBehave.Enum.NodeState `__getter`
---@field RootNode NPBehave.Root
---@field ParentNode? NPBehave.Container
---@field Label string 显示标签
---@field Name string
---@field Blackboard NPBehave.Blackboard `__getter`
---@field Clock NPBehave.Clock `__getter`
---@field IsStopRequested boolean `__getter`
---@field IsActive boolean `__getter`
---@overload fun(name: string): NPBehave.Node
local Node = Class('NPBehave.Node')

local is_debug = y3.game.is_debug_mode()
---@class NPBehave.Node: NPBehave.Tool.MethodDecorator



Extends('NPBehave.Node', 'NPBehave.Tool.MethodDecorator')

---@diagnostic disable-next-line: undefined-field
Node.__getter.CurrentState = function(self)
    ---@cast self NPBehave.Node
    ---@diagnostic disable-next-line: invisible
    return self.currentState
end

---@diagnostic disable-next-line: undefined-field
Node.__getter.Blackboard = function(self)
    ---@cast self NPBehave.Node
    ---@diagnostic disable-next-line: invisible
    return self.RootNode.Blackboard
end

---@diagnostic disable-next-line: undefined-field
Node.__getter.Clock = function(self)
    ---@cast self NPBehave.Node
    ---@diagnostic disable-next-line: invisible
    return self.RootNode.Clock
end

---@diagnostic disable-next-line: undefined-field
Node.__getter.IsStopRequested = function(self)
    ---@cast self NPBehave.Node
    ---@diagnostic disable-next-line: invisible
    return self.currentState == NPBehave.Enum.NodeState.StopRequested
end

---@diagnostic disable-next-line: undefined-field
Node.__getter.IsActive = function(self)
    ---@cast self NPBehave.Node
    ---@diagnostic disable-next-line: invisible
    return self.currentState == NPBehave.Enum.NodeState.Active
end

---@param name string
---@return self
function Node:__init(name)
    self.Name         = name
    self.currentState = NPBehave.Enum.NodeState.Inactive
    -- #region MARK: DEBUG
    if is_debug then
        self.DebugLastStopRequestAt = 0
        self.DebugLastStoppedAt     = 0
        self.DebugNumStartCalls     = 0
        self.DebugNumStopCalls      = 0
        self.DebugNumStoppedCalls   = 0
        self.DebugLastResult        = false
    end
    -- #endregion
    return self
end

---virtual<br>
---@param rootNode NPBehave.Root
function Node:SetRoot(rootNode)
    self.RootNode = rootNode
end

---@param parentNode NPBehave.Container
function Node:SetParent(parentNode)
    self.ParentNode = parentNode
end

function Node:Start()
    assert(self.currentState == NPBehave.Enum.NodeState.Inactive, '只能启动非活动节点')
    self.currentState = NPBehave.Enum.NodeState.Active
    if is_debug then
        self.RootNode.TotalNumStartCalls = self.RootNode.TotalNumStartCalls + 1
        self.DebugNumStartCalls          = self.DebugNumStartCalls + 1
    end
    self:DoStart()
end

function Node:CancelWithoutReturnResult()
    assert(self.currentState == NPBehave.Enum.NodeState.Active, '只能停止活动节点，试图停止')
    self.currentState = NPBehave.Enum.NodeState.StopRequested
    if is_debug then
        self.RootNode.TotalNumStopCalls = self.RootNode.TotalNumStopCalls + 1
        self.DebugLastStopRequestAt     = y3.game.current_game_run_time()
        self.DebugNumStopCalls          = self.DebugNumStopCalls + 1
    end
    self:DoCancel()
end

---@protected
---virtual<br>
function Node:DoStart()
end
---@protected
---virtual<br>
function Node:DoCancel()
end

---@protected 
---virtual<br>
---这绝对必须是函数中的最后一个调用, 调用停止后切勿修改任何状态!!! 
function Node:Stopped(success)
    assert(self.currentState ~= NPBehave.Enum.NodeState.Inactive, '在 `INACTIVE` 状态下调用了 `Stopped`, 说明出了问题')
    self.currentState = NPBehave.Enum.NodeState.Inactive
    if is_debug then
        self.RootNode.TotalNumStoppedCalls = self.RootNode.TotalNumStoppedCalls + 1
        self.DebugNumStoppedCalls          = self.DebugNumStoppedCalls + 1
        self.DebugLastStoppedAt            = y3.game.current_game_run_time()
        self.DebugLastResult               = success
    end
    if self.ParentNode ~= nil then
        self.ParentNode:ChildStopped(self, success)
    end
end

---virtual<br>
---@param composite NPBehave.Composite.Composite
function Node:ParentCompositeStopped(composite)
    self:DoParentCompositeStopped(composite)
end


---@protected
---virtual<br>
-- 处于非活动状态时调用, 目的是让装饰者删除任何正在等待的观察者.
---@param composite NPBehave.Composite.Composite
function Node:DoParentCompositeStopped(composite)
    -- 小心调用
end

---override<br>
function Node:__tostring()
    return self.Label ~= nil and self.Name .. '{' .. self.Label .. '}' or self.Name
end

---@protected
function Node:GetPath()
    if self.ParentNode ~= nil then
        return self.ParentNode:GetPath() .. '/' .. self.Name
    else
        return self.Name
    end
end

return Node
