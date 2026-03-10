require('Network.CommonLogic.Datagrams.NegotiationProtocols.BaseNegotiationProtocol')

---@param task_data string
---@return string
local function parse(task_data)
    local address = string.match(task_data, "DENY<(.+)>")
    return address
end

---@param endpoint EndpointLogic.Endpoint
---@param task_data string
---@param END EndpointNegotiationDatagram
---@return boolean
local function onEndpointReceive(endpoint, task_data, END)
    local end_address = parse(task_data)
    if end_address == endpoint.memory.address then
        endpoint:dumpAddress()
        return true
    elseif end_address then
        return true
    else
        return false
    end
end

---@param router Router
---@param task_data string
---@param END EndpointNegotiationDatagram
---@return boolean
local function onRouterReceive(router, task_data, END)
    -- do nothing
    local end_address = parse(task_data)
    if end_address then return true end
    return false
end

---@param endpoint_address ?string
---@return string
function DenySubprotocol(endpoint_address)
    return string.format("DENY<%s>",endpoint_address)
end

---@type NegotiationSubprotocol
local protocol = {
    onEndpointReceive = onEndpointReceive,
    onRouterReceive = onRouterReceive,
    name = "DenySubprotocol"
}

table.insert(END_NEGOTIATION_TASKS,protocol)