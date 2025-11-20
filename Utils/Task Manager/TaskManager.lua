require('Task')
--- TODO: parents

---@class TaskManager
---@field doTick fun(self:TaskManager, dTMilis: integer)
---@field tasks table<string,Task>
---@field addTask fun(self:TaskManager, task: Task, parent: Task | nil)
---@field time integer
---@field tkill fun(self: TaskManager, taskName: string)
---@field toString fun()

---@param self TaskManager
---@param dTMilis integer
local function doTick(self, dTMilis)
    time = time + dTMilis
    for taskName, task in pairs(self.tasks) do
        if task.shouldDie then
            task.onDie()
            self.tasks[taskName] = nil
            goto continue
        end
        if time - task.lastUpdated > task.maxUpdate or task.lastUpdated < 0 then
            task.run(time)
            task.lastUpdated = time
        end
        ::continue::
    end
end

local function addTask(self, task, parent)
    self.tasks[task.name] = task
    task.parent = parent
end

---@param self TaskManager
local function taskManagerToString(self)
    ret = string.format("TSKMGR TIME = %d",self.time)
    for taskName, task in pairs(self.tasks) do
        ret = ret .. task:toString() .. "\n"
    end
    return ret
end

---@param self TaskManager
local function tkill(self, taskName)
    local task = self.tasks[taskName]
    if not task then return false end
    task.shouldDie = true
end

---@return TaskManager
TaskManager = function ()
    ---@type TaskManager
    return {
        doTick = doTick,
        addTask = addTask,
        toString = taskManagerToString,
        tasks = {},
        tkill = tkill,
        time = 0
    }
end
