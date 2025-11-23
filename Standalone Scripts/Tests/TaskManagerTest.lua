require('Utils.TaskManager.TaskManager')

local t = os.time()
local last = t

m = TaskManager()

for t = 1, 5 do
    local name = string.format("task %d",t)
    local t = Task(
        name,
        t*10,
        function (self)
            print("T",name)
        end
    )
    m:addTask(t)
end

for i = 1, 1/0 do
    while t - last < 1 do
        t = os.time()
    end
    print(i,t,last,t-last)
    m:doTick(1)
    last = t
end