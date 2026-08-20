---@enum NPBehaveClassName
local NPBehaveClassName = {
    Node                = 'NPBehave.Node',
    Root                = 'NPBehave.Root',



    Decorator           = 'NPBehave.Decorator.Decorator',
    ObservingDecorator  = 'NPBehave.Decorator.ObservingDecorator',
    -- - 只有当黑板的键匹配op / value条件时，才执行decoratee节点。
    -- - 如果stopsOnChange不是NONE，则节点将根据stopsOnChange stop规则观察黑板上的变化并停止运行节点的执行。
    ---@see NPBehave.Decorator.BlackboardCondition
    BlackboardCondition = 'NPBehave.Decorator.BlackboardCondition',
    -- 运行给定的服务函数，启动decoratee，然后在给定的时间间隔内以随机变量的方式运行服务。
    ---@see NPBehave.Decorator.Service
    Service             = 'NPBehave.Decorator.Service',
    -- - 观察多个黑板键，并在其中一个值发生变化时立即计算给定的查询函数
    -- - 从而允许您在黑板上执行任意查询。
    -- - 它将根据stopsOnChange stop规则停止运行节点。
    ---@see NPBehave.Decorator.BlackboardQuery
    BlackboardQuery     = 'NPBehave.Decorator.BlackboardQuery',
    -- - 如果给定条件返回true，则执行decoratee节点。
    -- - 在给定的校验间隔和随机方差处重新评估条件，并根据stopsOnChange stop规则停止运行节点。
    ---@see NPBehave.Decorator.Condition
    Condition           = 'NPBehave.Decorator.Condition',
    -- - 立即运行decoratee，但前提最后一次执行超过cooldownTime，randomVariation修饰
    -- - 当startAfterDecoratee为true时，将在decoratee完成后而不是启动时启动冷却计时器。
    -- - 当resetOnFailure为真时，如果修饰节点失败，则重置冷却时间。
    ---@see NPBehave.Decorator.Cooldown
    Cooldown            = 'NPBehave.Decorator.Cooldown',
    -- 总是失败，不管装饰者的结果如何。
    ---@see NPBehave.Decorator.Failer
    Failer              = 'NPBehave.Decorator.Failer',
    Hook                = 'NPBehave.Decorator.Hook',
    -- 如果decoratee成功，则逆变器失败;如果decoratee失败，则逆变器成功。
    ---@see NPBehave.Decorator.Inverter
    Inverter            = 'NPBehave.Decorator.Inverter',
    -- - 一旦decoratee启动，运行给定的onStart lambda;
    -- - 一旦decoratee结束，运行onStop(bool result) lambda。
    -- - 它有点像一种特殊的服务，因为它不会直接干扰decoratee的执行。
    ---@see NPBehave.Decorator.Observer
    Observer            = 'NPBehave.Decorator.Observer',
    -- 以给定的概率，0到1运行decoratee。
    ---@see NPBehave.Decorator.Random
    Random              = 'NPBehave.Decorator.Random',
    -- - 执行给定的decoratee循环次数(0表示decoratee永远不会运行)。
    -- - 如果decoratee停止，循环将中止，并且中继器失败。
    -- - 如果decoratee的所有执行都成功，那么中继器将会成功。
    ---@see NPBehave.Decorator.Repeater
    Repeater            = 'NPBehave.Decorator.Repeater',
    -- 永远要成功，不管装饰器是否成功
    ---@see NPBehave.Decorator.Succeeder
    Succeeder           = 'NPBehave.Decorator.Succeeder',
    -- - 运行给定的decoratee。
    -- - 如果decoratee没有在限制和随机变化范围内完成，则执行将失败。
    -- - 如果waitforchildbutfailonlimitarrived为true，它将等待decoratee完成，但仍然失败。
    ---@see NPBehave.Decorator.TimeMax
    TimeMax             = 'NPBehave.Decorator.TimeMax',
    -- - 运行给定的decoratee。
    -- - 如果decoratee在达到随机变化时间限制之前成功完成，decorator将等待直到达到限制，然后根据decoratee的结果停止执行。
    -- - 如果waitOnFailure为真，那么当decoratee失败时，decoratee也将等待。
    ---@see NPBehave.Decorator.TimeMin
    TimeMin             = 'NPBehave.Decorator.TimeMin',
    -- 延迟decoratee节点的执行，直到条件为真，使用给定的checkInterval和randomVariance进行检查
    ---@see NPBehave.Decorator.WaitForCondition
    WaitForCondition    = 'NPBehave.Decorator.WaitForCondition',
    Composite           = 'NPBehave.Composite.Composite',
    -- 按顺序运行子节点，直到其中一个失败(如果所有子节点都没有失败，则成功)。
    Sequence            = 'NPBehave.Composite.Sequence',
    -- - 当failurePolicy为ONE。当其中一个孩子失败时，并行就停止，返回失败。
    -- - 当successPolicy为ONE。当其中一个孩子失败时，并行将停止，返回成功。
    -- - 如果并行没有因为Policy.ONE而停止。它会一直执行，直到所有的子节点都完成，然后如果所有的子节点都成功或者失败，它就会返回成功。
    ---@see NPBehave.Composite.Parallel
    Parallel            = 'NPBehave.Composite.Parallel',
    -- 按顺序运行子节点，直到其中一个子节点成功(如果其中一个子节点成功，则成功)。
    Selector            = 'NPBehave.Composite.Selector',
    -- - 按随机顺序运行子进程，直到其中一个子进程成功(如果其中一个子进程成功，则成功)。
    -- - 注意，对于打断规则，最初的顺序定义了优先级。
    ---@see NPBehave.Composite.RandomSelector
    RandomSelector      = 'NPBehave.Composite.RandomSelector',
    -- - 以随机顺序运行子节点，直到其中一个失败(如果没有子节点失败，则成功)。
    -- - 注意，对于打断规则，最初的顺序定义了优先级。
    ---@see NPBehave.Composite.RandomSequence
    RandomSequence      = 'NPBehave.Composite.RandomSequence',
    -- - `action` 总是立即成功完成
    -- - `singleFrameFunc` 可以成功或失败的操作(返回false to fail)
    -- - `multiFrameFunc` 可以在多个帧上执行的操作
    -- > Result.BLOCKED——你的行动还没有准备好<br>
    -- > Result.PROGRESS——当你忙着这个行为的时候<br>
    -- > Result.SUCCESS或Result.FAILED——成功或失败
    -- - `multiFrameFunc2` 与上面类似，Request会给你一个状态信息: Request.START表示它是您的操作或返回结果的第一个标记或者是Result.BLOCKED最后一个标记。 Request.UPDATE表示您最后一次返回Request.PROGRESS; Request.CANCEL意味着您需要取消操作并返回结果。成功或者Result.FAILED
    ---@see NPBehave.Task.Action
    Action              = 'NPBehave.Task.Action',
    Task                = 'NPBehave.Task.Task',
    -- - 等待被其他节点停止。
    -- - 它通常用于Selector的末尾，等待任何before头的同级BlackboardCondition、BlackboardQuery或Condition变为活动状态。
    ---@see NPBehave.Task.WaitUntilStopped
    WaitUntilStopped    = 'NPBehave.Task.WaitUntilStopped',
    -- 等待在给定的blackboardKey中设置为float的秒数
    ---@see NPBehave.Task.WaitSeconds
    Wait                = 'NPBehave.Task.Wait',
}

return NPBehaveClassName
