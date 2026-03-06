--MSG<(destination_address)-(sender_address)-confirm:T|F-multicast:T|F-(message_content)>
require('Network.CommonLogic.Datagrams.NegotiationProtocols.BaseNegotiationProtocol')

---@param task_data string
---@return string | nil, string, 'T'|'F', 'T'|'F', string
local function parse(task_data)
    local destination_address, sender_address, confirm, multicast, message =
        string.match(task_data, "MSG<%((.+)%)%-%((.+)%)%-([TF])%-([TF])%-%((.+)%)>")
    return destination_address, sender_address, confirm, multicast, message
end

---@param destination_address string
---@param sender_address string
---@param confirm 'T'|'F'
---@param multicast 'T'|'F'
---@param message string
---@return string
function MessageSubprotocol(destination_address, sender_address, confirm, multicast, message)
    return string.format("MSG<(%s)-(%s)-%s-%s-(%s)>",
        destination_address, sender_address, confirm, multicast, message
    )
end

---@param endpoint EndpointLogic.Endpoint 
---@param task_data string
---@param END EndpointNegotiationDatagram
---@return boolean
local function onEndpointReceive(endpoint, task_data, END)
    local destination_address, sender_address, confirm, multicast, message = parse(task_data)
    if not destination_address then return false end
    if END.who_sent_it == 'E' or END.endpoint_address ~= endpoint.memory.address then
        return true
    end
    
    endpoint:pullArrivedMessage({
        from = sender_address,
        to = destination_address,
        message = message
    })
    return true
end

---@param router Router
---@param task_data string
---@param END EndpointNegotiationDatagram
---@return boolean
local function onRouterReceive(router, task_data, END)
    local destination_address, sender_address, confirm_s, multicast_s, message = parse(task_data)
    if not destination_address then return false end
    if END.who_sent_it == 'R' or END.router_address ~= router.name then
        return true
    end

    local multicast = multicast_s == 'T'
    local confirm = confirm_s == 'T' -- TODO

    local destination = router.memory.network_state:getEndpointWithName(destination_address)
    if not destination then
        STD_WARN('task ' .. task_data)
        STD_WARN('Got message request but could not fullfill it because the adress ' .. destination_address .. ' does not exist')
        -- error'invalid msg' 
        return true
    end
    local last_router = destination.parent_router
    local path = last_router.path_to:removeFirst()
    
    if router.name == last_router.name then
        local new_task = MessageSubprotocol(destination_address,sender_address,confirm_s,multicast_s,message)
        local negotiation_d = EndpointNegotiationDatagram(destination_address, router.name, 'R', new_task)
        router:transmit(negotiation_d:toString())
        return true
    end

    if path:isEmpty() then
        STD_ERR('message ' .. END:toString())
        STD_ERR('task ' .. task_data)
        error 'path for message is empty but still not at final router'
    end

    require('Network.RouterLogic.Datagrams.MessageDatagram')
    local to_send = MessageDatagram(END.endpoint_address,
        path.path[1], path.path[#path.path],
        destination_address, 30, confirm,
        path:toString(),message
    )

    if last_router == router.name then
        router:onReceive(to_send:toString())
    else
        router:transmit(to_send:toString())
    end

    return true
end

---@type NegotiationSubprotocol
local protocol = {
    onEndpointReceive = onEndpointReceive,
    onRouterReceive = onRouterReceive,
    name = "MessageSubprotocol"
}

table.insert(END_NEGOTIATION_TASKS,protocol)