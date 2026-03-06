require('Telecom')
require('Network.EndpointLogic.Endpoint')
require('Network.EndpointLogic.Firmware.RadioEndpoint')
require('Utils.TaskManager.TaskManager')

TASK_MANAGER = TASK_MANAGER or TaskManager()

FREQUENCY = FREQUENCY or 2223
endpoint_r = RadioEndpoint(FREQUENCY)
endpoint_r:begin()

shell.run("cp Telecom/Startup/RadioEndpointStartup.lua startup.lua")

TASK_MANAGER:addTask(
    Task('ENDPOINT_LOGIC', 250,
        function (self, deltaT)
            endpoint_r:doTick()
        end
    )
)

SEQ = 1

TASK_MANAGER:addTask(
    Task('SEND_PING', 10 * 1000,
        function (self, deltaT)
            if not endpoint_r.endpoint.memory.address then
                STD_ERR("Endpoint not connected, cannot send message")
            else
                local ends = endpoint_r.endpoint:get_endpoints_at_network()
                for name, endpoint in pairs(ends) do
                    if endpoint.address == endpoint_r.endpoint.memory.address then
                        goto continue
                    end
                    STD_OUT('sending ping to ' .. name)
                    local msg = endpoint_r.endpoint.memory.address ..
                    ' says hi :) [' .. SEQ .. ']' .. tostring(endpoint_r.endpoint.time)
                    endpoint_r.endpoint:send_message_to(name, msg)
                    ::continue::
                end
                SEQ = SEQ + 1
            end
        end
    )
)

os.startTimer(1)

while true do
    local event, side, msg, distance = os.pullEvent()
    if event == 'timer' then
        local time = math.floor(1000 * os.clock())
        TASK_MANAGER:doTick(1000 * 0.05)
        os.startTimer(.05)
    elseif event == 'radio_message' then
        endpoint_r:onMessageReceived(event,side,msg,distance)
    end
end

