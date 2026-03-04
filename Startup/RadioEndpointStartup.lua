require('Telecom')
require('Network.EndpointLogic.Endpoint')
require('Network.EndpointLogic.Firmware.RadioEndpoint')
require('Utils.TaskManager.TaskManager')

TASK_MANAGER = TASK_MANAGER or TaskManager()

FREQUENCY = FREQUENCY or 2223
endpoint_r = RadioEndpoint(FREQUENCY)
endpoint_r:begin()

TASK_MANAGER:addTask(
    Task('ENDPOINT_LOGIC', 20,
        function (self, deltaT)
            endpoint_r:doTick()
        end
    )
)

TASK_MANAGER:addTask(
    Task('SEND_PING', 10 * 1000,
        function (self, deltaT)
            if not endpoint_r.endpoint.memory.address then
                STD_ERR("Endpoint not connected, cannot send message")
            else
                local ends = endpoint_r.endpoint:get_endpoints_at_network()
                for name, endpoint in pairs(ends) do
                    STD_OUT('sending msg to ' .. name)
                    local msg = endpoint_r.endpoint.memory.address ..  ' TESTE ' .. tostring(endpoint_r.endpoint.time)
                    endpoint_r.endpoint:send_message_to(name,msg)
                end
            end
        end
    )
)

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

