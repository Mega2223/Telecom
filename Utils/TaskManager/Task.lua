---@class Task
---@field maxUpdate integer
---@field lastUpdated integer
---@field run fun(self: Task,time: integer)
---@field parent Task | nil
---@field name string
---@field shouldDie boolean
---@field onDie ?fun(self: Task, deltaT: integer)
---@field toString fun()

---@param self Task
local function taskToString(self)
    local parentName = "NULL"
    if self.parent then parentName = self.parent.name end
    return string.format("TASK %s PARENT %s LAST_UPDATE %d",self.name,parentName,self.lastUpdated)
end

---@param name string
---@param maxUpdate integer
---@param runFunction fun(self: Task, deltaT: integer)
---@param deathFunction ?fun(self: Task, deltaT: integer)
---@return Task
Task = function (name, maxUpdate, runFunction, deathFunction)
    ---@type Task
    return {
        name = name,
        maxUpdate = maxUpdate,
        run = runFunction,
        lastUpdated = -1,
        shouldDie = false,
        onDie = deathFunction,
        toString = taskToString
    }
end