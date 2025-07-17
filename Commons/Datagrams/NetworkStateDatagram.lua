---@type table<string, DatagramParser>
NETWORK_DATAGRAM_PROT = NETWORK_DATAGRAM_PROT or {}

---@class NetworkStateDatagram
---@field router string
---@field data string
---@field is_reply boolean
---@field toString fun(self: NetworkStateDatagram): string

---@param self NetworkStateDatagram
---@return string
local function toString(self)
    ---[NSD-%ROUTER_NAME%-(%DATA%)]
    return string.format("[NSD-%q-(%q)]",self.router,self.data)
end

---@param data string
---@return NetworkStateDatagram | nil
local function parseNetworkStateDatagram(data)
    local router, data = string.match(data,"%[NSD%-(.+)%-%((.+)%)%]")
    if not router then return nil end
    return NetworkStateDatagram(router, data)
end

---Creates a NetworkStateDatagram object
---@param router string
---@param data string
---@return NetworkStateDatagram
function NetworkStateDatagram(router, data)
    ---@type NetworkStateDatagram
    return {
        router = router,
        data = data,
        is_reply = data ~= 'REQUEST',
        toString = toString
    }
end

---@param msg string
---@param router Router
local function onMessageReceived(msg, router)
    local datagram = parseNetworkStateDatagram(msg)
    if not datagram then return false end
    if not (datagram.is_reply) and datagram.router == router.configs.name then
        local answer = NetworkStateDatagram(
            datagram.name,
            router.memory:toString()
        )
        router:transmit(answer:toString())
    end
    return true
end

local function onDie()
    
end

local template_parser = {
    onDie = onDie,
    onMessageReceived = onMessageReceived,
    type = 'NetworkStateDatagramParser'
}

table.insert(NETWORK_DATAGRAM_PROT,template_parser)