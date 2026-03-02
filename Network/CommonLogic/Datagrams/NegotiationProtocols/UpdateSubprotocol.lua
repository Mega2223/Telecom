require('Network.CommonLogic.Datagrams.EndpointNegotiationDatagram')
require('Network.CommonLogic.Datagrams.NegotiationProtocols.BaseNegotiationProtocol')

-- Talvez seja interessante ter um montador em classes similar as classes dos datagramas

---@param endpoint EndpointLogic.Endpoint
---@param task_data string
---@param END EndpointNegotiationDatagram
---@return boolean
local function onEndpointReceive(endpoint, task_data, END)
    if task_data == 'UPDATE' then
        return true
    end
    return false
end

---@param router Router
---@param task_data string
---@param END EndpointNegotiationDatagram
---@return boolean
local function onRouterReceive(router, task_data, END)
    if task_data == 'UPDATE' then
        router.memory:updateEndpoint(END.endpoint_address, router.current_time_milis)
        return true
    end
    return false
end

---@type NegotiationSubprotocol
local protocol = {
    onEndpointReceive = onEndpointReceive,
    onRouterReceive = onRouterReceive
}

table.insert(END_NEGOTIATION_TASKS,protocol)