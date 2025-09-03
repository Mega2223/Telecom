require('Commons.Datagrams.Datagram')

-- The discovery datagram is made for routers to find out adjacent routers through a ping

NETWORK_DATAGRAM_PROT = NETWORK_DATAGRAM_PROT or {}

---@enum ENDPOINT_CONTRACT_TASK
ENDPOINT_CONTRACT_TASKS = {
    ASK_CONNECTION='ASK_CONNECTION',
    CONFIRM_CONNECTION='CONFIRM_CONNECTION',
    RENEW_CONNECTION='RENEW_CONNECTION',
    PING_NEARBY='PING_NEARBY',
    NEARBY_ROUTER='NEARBY_ROUTER',
    ASK_ADDRESSES='ASK_ADDRESSES',
    REPLY_ADDRESSES='REPLY_ADDRESSES'
}

---@param self EndpointContractDatagram
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