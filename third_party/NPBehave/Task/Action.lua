local assert = assert
---@class NPBehave.Task.Action
---@overload fun(data: NPBehave.Task.Action.InitParam): NPBehave.Task.Action
local Action = Class('NPBehave.Task.Action')

local superName = 'NPBehave.Task.Task'
---@class NPBehave.Task.Action: NPBehave.Task.Task
Extends('NPBehave.Task.Action', superName, function(self, super, ...)
    super('Action')
end)




---@class NPBehave.Task.Action.InitParam
---@field action? fun()
---@field multiFrameFunc? fun(cancel: boolean): NPBehave.Enum.ActionResult
---@field multiFrameFunc2? fun(request: NPBehave.Enum.ActionRequest): NPBehave.Enum.ActionResult
---@field singleFrameFunc? fun(): boolean

---@param data NPBehave.Task.Action.InitParam
---@return self
function Action:__init(data)
    self._singleFrameFunc = data.singleFrameFunc
    self._multiFrameFunc = data.multiFrameFunc
    self._multiFrameFunc2 = data.multiFrameFunc2
    self._action = data.action
    self._bWasBlocked = false
    return self
end

---override<br>
---@protected
function Action:DoStart()
    if self._action ~= nil then
        self._action()
        self:Stopped(true)
    elseif self._multiFrameFunc ~= nil then
        local result = self._multiFrameFunc(false)
        if result == NPBehave.Enum.ActionResult.Progress then
            self.RootNode.Clock:AddUpdateObserver(self:bind(self.OnUpdateFunc))
        elseif result == NPBehave.Enum.ActionResult.Blocked then
            self._bWasBlocked = true
            self.RootNode.Clock:AddUpdateObserver(self:bind(self.OnUpdateFunc))
        else
            self:Stopped(result == NPBehave.Enum.ActionResult.Success)
        end
    elseif self._multiFrameFunc2 ~= nil then
        local result = self._multiFrameFunc2(NPBehave.Enum.ActionRequest.Start)
        if result == NPBehave.Enum.ActionResult.Progress then
            self.RootNode.Clock:AddUpdateObserver(self:bind(self.OnUpdateFunc2))
        elseif result == NPBehave.Enum.ActionResult.Blocked then
            self._bWasBlocked = true
            self.RootNode.Clock:AddUpdateObserver(self:bind(self.OnUpdateFunc2))
        else
            self:Stopped(result == NPBehave.Enum.ActionResult.Success)
        end
    elseif self._singleFrameFunc ~= nil then
        self:Stopped(self._singleFrameFunc())
    end
end

---@private
function Action:OnUpdateFunc()
    local result = self._multiFrameFunc(false)
    if result ~= NPBehave.Enum.ActionResult.Progress and result ~= NPBehave.Enum.ActionResult.Blocked then
        self.RootNode.Clock:RemoveUpdateObserver(self:bind(self.OnUpdateFunc))
        self:Stopped(result == NPBehave.Enum.ActionResult.Success)
    end
end

---@private
function Action:OnUpdateFunc2()
    local result = self._multiFrameFunc2(self._bWasBlocked and NPBehave.Enum.ActionRequest.Start or
        NPBehave.Enum.ActionRequest.Update)
    if result == NPBehave.Enum.ActionResult.Blocked then
        self._bWasBlocked = true
    elseif result == NPBehave.Enum.ActionResult.Progress then
        self._bWasBlocked = false
    else
        self.RootNode.Clock:RemoveUpdateObserver(self:bind(self.OnUpdateFunc2))
        self:Stopped(result == NPBehave.Enum.ActionResult.Success)
    end
end

---override<br>
---@protected
function Action:DoCancel()
    if self._multiFrameFunc ~= nil then
        local result = self._multiFrameFunc(true)
        assert(result ~= NPBehave.Enum.ActionResult.Progress,
            'The Task has to return Result.SUCCESS, Result.FAILED/BLOCKED after being cancelled!')
        self.RootNode.Clock:RemoveUpdateObserver(self:bind(self.OnUpdateFunc))
        self:Stopped(result == NPBehave.Enum.ActionResult.Success)
    elseif self._multiFrameFunc2 ~= nil then
        local result = self._multiFrameFunc2(NPBehave.Enum.ActionRequest.Cancel)
        assert(result ~= NPBehave.Enum.ActionResult.Progress,
            'The Task has to return Result.SUCCESS or Result.FAILED/BLOCKED after being cancelled!')
        self.RootNode.Clock:RemoveUpdateObserver(self:bind(self.OnUpdateFunc2))
        self:Stopped(result == NPBehave.Enum.ActionResult.Success)
    else
        assert(false, 'DoStop called for a single frame action on ' .. tostring(self))
    end
end

return Action
