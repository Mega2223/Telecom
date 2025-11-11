--- TODO: parents

---@class Task
---@field maxUpdate integer
---@field lastUpdated integer
---@field run function
---@field parent Task | nil
---@field name string

---@class TaskManager
---@field doTick fun(self:TaskManager, dTMilis: integer)
---@field tasks table<string,Task>
---@field addTask fun(self:TaskManager, task: Task, parent: Task | nil)
---@field time integer

local function doTick(self, dTMilis)
    time = time + dTMilis
    for ignored, task in pairs(self.tasks) do
        if time - task.lastUpdated > task.maxUpdate or task.lastUpdated < 0 then
            task.run()
            task.lastUpdated = time
        end
    end
end

local function addTask(self, task, parent)
    self.tasks[task.name] = task
    task.parent = parent
end

---@return TaskManager
TaskManager = function ()
    ---@type TaskManager
    return {
        doTick = doTick,
        addTask = addTask,
        tasks = {},
        time = 0
    }
end

---@return Task
Task = function (name, maxUpdate, runFunction)
    ---@type Task
    return {
        name = name,
        maxUpdate = maxUpdate,
        run = runFunction,
        lastUpdated = -1
    }
end