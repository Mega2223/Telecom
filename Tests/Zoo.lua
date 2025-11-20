require('Network.RouterLogic.Datagrams.DiscoveryDatagram')
require('Network.Router')
require('Network.Wrapper.DebugWrapper')

---@type table<integer,DebugWrapper>
local wrappers = {}

local function onSent(dat)
    --print('MSG_STREAM:',dat)
    for i = 1, #wrappers do
        wrappers[i]:receiveMessage(dat)
    end
end

for i = 1, 4 do
    wrappers[i] = DebugWrapper(
        Router({}),
        onSent
    )
end

for i = 1, #wrappers do
    wrappers[i]:begin()
end

local tick = 0
while tick do
    --print('TICK ', tick)
    for i = 1, #wrappers do
        wrappers[i]:runTick()
    end
    tick = tick + 1
    --print(wrapper.iteration)
end