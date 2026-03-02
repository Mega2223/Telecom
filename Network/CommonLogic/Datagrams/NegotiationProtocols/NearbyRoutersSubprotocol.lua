-- NEARBY_ROUTERS<ROUTER_NAME|nil>

require('Network.CommonLogic.Datagrams.NegotiationProtocols.BaseNegotiationProtocol')

---@param task_data string
---@return string
local function parse(task_data)
    local router_name = string.match(task_data, "NEARBY_ROUTERS<(.+)>")
    return router_name
end

---@param endpoint EndpointLogic.Endpoint
---@param task_data string
---@param END EndpointNegotiationDatagram
---@return boolean
local function onEndpointReceive(endpoint, task_data, END)
    local router_name = parse(task_data)
    if not router_name then return false end
    if END.who_sent_it == 'E' then return true end
    endpoint.memory.nearby_routers[END.router_address] = {
        name = END.router_address, last_seen = endpoint.time
    }
    return true
end

---@param router Router
---@param task_data string
---@param END EndpointNegotiationDatagram
---@return boolean
local function onRouterReceive(router, task_data, END)
    local router_name = parse(task_data)
    if not router_name then return false end
    if END.who_sent_it == 'R' then return true end
    local new_task = string.format("NEARBY_ROUTERS<%s>", router.name)
    local msg = EndpointNegotiationDatagram(END.endpoint_address, router.name, 'R', new_task)
    router:transmit(msg:toString())
    return true
end

---@param router_name ?string
---@return string
function NearbyRoutersTask(router_name)
    router_name = router_name or 'nil'
    return string.format("NEARBY_ROUTERS<%s>",router_name)
end

---@type NegotiationSubprotocol
local protocol = {
    onEndpointReceive = onEndpointReceive,
    onRouterReceive = onRouterReceive,
    name = "NearbyRoutersSubprotocol"
}

table.insert(END_NEGOTIATION_TASKS,protocol)