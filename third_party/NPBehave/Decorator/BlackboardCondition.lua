local assert = assert
local type = type
---@class NPBehave.Decorator.BlackboardCondition
---@overload fun(key: string, op: NPBehave.Enum.Operator, value: any, stopsOnChange: NPBehave.Enum.Stops, decoratee: NPBehave.Node): NPBehave.Decorator.BlackboardCondition
local BlackboardCondition = Class(NPBehave.ClassName.BlackboardCondition)
local superName = NPBehave.ClassName.ObservingDecorator

---@class NPBehave.Decorator.BlackboardCondition: NPBehave.Decorator.ObservingDecorator
Extends(NPBehave.ClassName.BlackboardCondition, superName, function(self, super, ...)
    local key, op, value, stopsOnChange, decoratee = ...
    super('BlackboardCondition', stopsOnChange, decoratee)
end)


---@param key string
---@param op NPBehave.Enum.Operator
---@param value? any
---@param stopsOnChange NPBehave.Enum.Stops
---@param decoratee NPBehave.Node
---@return unknown
function BlackboardCondition:__init(key, op, value, stopsOnChange, decoratee)
    self._op = op;
    self._key = key;
    self._value = value;
    self.StopsOnChange = stopsOnChange;
    return self
end

---override<br>
---@protected
function BlackboardCondition:StartObserving()
    ---@diagnostic disable-next-line: param-type-mismatch
    self.RootNode.Blackboard:AddObserver(self._key, self:bind(self.OnValueChanged))
end

---override<br>
---@protected
function BlackboardCondition:StopObserving()
    ---@diagnostic disable-next-line: param-type-mismatch
    self.RootNode.Blackboard:RemoveObserver(self._key, self:bind(self.OnValueChanged))
end

---@private
---@param type NPBehaveBlackboardType
---@param newValue any
function BlackboardCondition:OnValueChanged(type, newValue)
    self:Evaluate()
end

local switch = y3.util.switch()
    :case('AlwaysTrue'):call(function(curr_val, cond_val)
        return true
    end)
    :case('IsNotSet'):call(function(curr_val, cond_val)
        return curr_val == nil
    end)
    :case('IsSet'):call(function(curr_val, cond_val)
        return curr_val ~= nil
    end)
    :case('IsEqual'):call(function(curr_val, cond_val)
        return curr_val == cond_val
    end)
    :case('IsNotEqual'):call(function(curr_val, cond_val)
        return curr_val ~= cond_val
    end)
    :case('IsGreaterOrEqual'):call(function(curr_val, cond_val)
        local o = curr_val
        return type(o) == 'number' and o >= cond_val or false
    end)
    :case('IsGreater'):call(function(curr_val, cond_val)
        local o = curr_val
        return type(o) == 'number' and o > cond_val or false
    end)
    :case('IsSmallerOrEqual'):call(function(curr_val, cond_val)
        local o = curr_val
        return type(o) == 'number' and o <= cond_val or false
    end)
    :case('IsSmaller'):call(function(curr_val, cond_val)
        local o = curr_val
        return type(o) == 'number' and o < cond_val or false
    end)
---override<br>
---@protected
---@return boolean
function BlackboardCondition:IsConditionMet()

    return switch(self._op, self.RootNode.Blackboard:Get(self._key), self._value)
    end


---@type table<NPBehave.Enum.Operator,string>
local operatorToString = {
    IsSet            = '*',
    IsNotSet         = '?',
    IsEqual          = '=',
    IsNotEqual       = '≠',
    IsGreaterOrEqual = '≥',
    IsGreater        = '>',
    IsSmallerOrEqual = '≤',
    IsSmaller        = '<',
    AlwaysTrue       = '✓'
}

---override<br>
---@return string
function BlackboardCondition:__tostring()
    return self._key .. operatorToString[self._op] .. tostring(self._value)
end

return BlackboardCondition
