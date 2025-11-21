require('Datagram')

NETWORK_DATAGRAM_PROT = NETWORK_DATAGRAM_PROT or {}

---@enum ENDPOINT_CONTRACT_TASK
ENDPOINT_CONTRACT_TASKS = {
    ASK_CONNECTION='ASK_CONNECTION', --- Endpoint asks for connection
    CONFIRM_CONNECTION='CONFIRM_CONNECTION', --- Router confirms connection
    RENEW_CONNECTION='RENEW_CONNECTION', --- Router asks for connection renew / endpoint answers
    PING_NEARBY='PING_NEARBY', --- Endpoint asks for nearby router names
    NEARBY_ROUTER='NEARBY_ROUTER', --- Router answers name request
    ASK_ADDRESSES='ASK_ADDRESSES', --- Asks router for all endpoints in the network that matches the pattern
    REPLY_ADDRESSES='REPLY_ADDRESSES' --- Router answers endpoint name request
}

---@param self EndpointContractDatagram The endpoint contract datagram is a datagram that regulates endpoint to router connections
---@return string
local function toString(self)
    --[ECD-[%TASK%]-[%DESTINATION%]-(%TASK_DATA%)]
    return string.format("[ECT-[(%s)]-[%s]-(%s)]",self.task,self.destination,self.task_data)
end

---@class (exact) EndpointContractDatagram
---@field task ENDPOINT_CONTRACT_TASK
---@field task_data string
---@field destination string
---@field toString fun(self: EndpointContractDatagram): string
---@field type 'EndpointContractDatagram'

---@param destination string | nil
---@param task ENDPOINT_CONTRACT_TASK
---@param task_data ?string
---@return EndpointContractDatagram
function EndpointContractDatagram(task,destination,task_data)
    ---@type EndpointContractDatagram
    return {
        task = task,
        destination = destination or "",
        task_data = task_data or "",
        type = 'EndpointContractDatagram',
        toString = toString
    }
end

---@param data string
---@param router Router
---@return boolean
local function onMessageReceivedRouter(data, router)
    
end

local function onMessageReceivedTransport(data, transport)

end

local function onDie()
    -- Do nothing
end

---@type DatagramParser
local discovery = {
    onDie = onDie,
    onMessageReceived = onMessageReceivedRouter,
    type = 'DiscoveryDatagramParser'
}

table.insert(NETWORK_DATAGRAM_PROT,discovery)

return DiscoveryDatagram