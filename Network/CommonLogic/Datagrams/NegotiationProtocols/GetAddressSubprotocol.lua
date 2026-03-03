--For when the endpoint wants to know about other endpoints
--  GET_ADDRESS<host_pattern|host_list> -> "give me all hosts that match this pattern"

require('Network.CommonLogic.Datagrams.NegotiationProtocols.BaseNegotiationProtocol')
require('Utils.Utils')

---@param task_data string
---@return string | nil
local function parse_for_string(task_data)
    local task_val = string.match(task_data, "GET_ADDRESS<([^<>]+)>")
    return task_val
end

---@param task_data string
---@return table<integer,string> | nil
local function parse_for_list(task_data)
    local task_val = parse_for_string(task_data)
    if not task_val then return nil end
    local table_values = stringToList(task_val)
    return table_values
end

---@param pattern_or_list string | table<integer,string>
---@return string
function GetAddressSubprotocol(pattern_or_list)
    local data
    if type(pattern_or_list) == "table" then
        data = listToString(pattern_or_list)
    else
        data = pattern_or_list
    end
    return string.format("GET_ADDRESS<%s>",data)
end

---@param endpoint EndpointLogic.Endpoint 
---@param task_data string
---@param END EndpointNegotiationDatagram
---@return boolean
local function onEndpointReceive(endpoint, task_data, END)
    local values = parse_for_list(task_data)
    if not values then return false end
    if END.who_sent_it == 'E' or END.endpoint_address ~= endpoint.memory.address then return true end
    if type(values) == "table" then
        for key, address in pairs(values) do
            endpoint.memory.known_network_endpoints[key] =
                EndpointMemoryKnownEndpoint(address, endpoint.time)
        end
    end
    return true
end

---@param router Router
---@param task_data string
---@param END EndpointNegotiationDatagram
local function onRouterReceive(router, task_data, END)
    local pattern = parse_for_string(task_data)
    if not pattern then return false end
    if END.who_sent_it == 'R' or END.router_address ~= router.name then
        return true --not for me
    end

    local endpoints = router.memory.network_state:getEndpointsMatchingPattern(pattern)
    ---@type table<integer,string>
    local endpoint_str = {}
    for index, value in pairs(endpoints) do
        endpoint_str[index] = value.address
    end

    local task = GetAddressSubprotocol(endpoint_str)
    local datagram = EndpointNegotiationDatagram(END.endpoint_address, END.router_address, 'R', task)
    router:transmit(datagram:toString())
    return true
end

---@type NegotiationSubprotocol
local protocol = {
    onEndpointReceive = onEndpointReceive,
    onRouterReceive = onRouterReceive,
    name = "GetAdressSubprotocol"
}

table.insert(END_NEGOTIATION_TASKS,protocol)