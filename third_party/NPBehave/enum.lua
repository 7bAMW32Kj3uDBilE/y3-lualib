local m = {}
---@enum NPBehave.Enum.NodeState
m.NodeState = {
    Inactive      = 'Inactive',
    Active        = 'Active',
    -- 节点当前正在停止，但尚未调用Stopped()来通知父节点
    StopRequested = 'StopRequested',
}

---@enum NPBehave.Enum.Stops
m.Stops = {
    -- 装饰器只会在启动时检查一次它的状态，并且永远不会停止任何正在运行的节点。
    None                          = 'None',
    -- 装饰器将在启动时检查一次它的条件状态，如果满足，它将继续观察黑板的变化。一旦不再满足该条件，它将终止自身，并让父组合继续处理它的下一个节点。
    Self                          = 'Self',
    -- 装饰器将在启动时检查它的状态，如果不满足，它将观察黑板的变化。一旦条件满足，它将停止比此结点优先级较低的节点，允许父组合继续处理下一个节点
    LowerPriority                 = 'LowerPriority',
    -- 装饰器将同时停止:self和优先级较低的节点。
    Both                          = 'Both',
    -- 一旦启动，装饰器将检查它的状态:
    -- - 如果不满足，它将观察黑板的变化。
    -- - 一旦条件满足，它将停止优先级较低的节点，并命令父组合立即重启装饰器。
    -- - 正如在这两种情况下，一旦不再满足条件，它也将停止自己。
    ImmediateRestart              = 'ImmediateRestart',
    -- 一旦启动，装饰器将检查它的状态，如果不满足，它将观察黑板的变化。一旦条件满足，它将停止优先级较低的节点，并命令父组合立即重启此装饰器。
    LowerPriorityImmediateRestart = 'LowerPriorityImmediateRestart'
}

---@enum NPBehave.Enum.Operator
m.Operator = {
    IsSet            = 'IsSet',
    IsNotSet         = 'IsNotSet',
    IsEqual          = 'IsEqual',
    IsNotEqual       = 'IsNotEqual',
    IsGreaterOrEqual = 'IsGreaterOrEqual',
    IsGreater        = 'IsGreater',
    IsSmallerOrEqual = 'IsSmallerOrEqual',
    IsSmaller        = 'IsSmaller',
    AlwaysTrue       = 'AlwaysTrue'
}

---@enum NPBehave.Enum.ParallelPolicy
m.ParallelPolicy = {
    One = 'One',
    All = 'All',
}
---@enum NPBehave.Enum.ActionResult
m.ActionResult = {
    Success  = 'Success',
    Failed   = 'Failed',
    -- 你的行动还没有准备好
    Blocked  = 'Blocked',
    -- 当你忙着这个行为的时候
    Progress = 'Progress'
}
---@enum NPBehave.Enum.ActionRequest
m.ActionRequest = {
    -- 表示它是您的操作或返回结果的第一个标记或者是Result.BLOCKED最后一个标记
    Start  = 'Start',
    -- 表示您最后一次返回
    Update = 'Update',
    -- 意味着您需要取消操作并返回结果
    Cancel = 'Cancel'
}
return m