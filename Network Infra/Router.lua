---@type table<integer,DatagramParser>
NETWORK_DATAGRAM_PROT = NETWORK_DATAGRAM_PROT or {}

require('DiscoveryDatagram')
require('NetworkState')
require('RouterMemory')

local function updateConnectedRouters(self)
    self.memory.adjacent_routers = {}
    local ask = DiscoveryDatagram(1,false,self.name)
    self:transmit(ask:toString())
end

--- @param self Router
--- @param msg string
local function transmitMessage(self, msg)
    return self.wrapper:transmitMessage(msg)
end

local function doTick(self)
    self.memory.iteration = self.memory.iteration + 1
end

local function onReceive(self, message)
    local datagram = message
    for i = 1, #NETWORK_DATAGRAM_PROT do
        local k = NETWORK_DATAGRAM_PROT[i]
        if NETWORK_DATAGRAM_PROT[i].onMessageReceived(datagram,self) then 
            return true
        end
    end
    print('Could not find fitting template for message:\n' .. message )
    return false
end

local function onStart(self)
    self.table = {} -- god bless the garbage collector
    self:updateConnectedRouters()
end

---@class Router Describes a router entity, which must be bound to a Wrapper entity
---@field transmit fun(self: Router,data: string): boolean
---@field doTick fun(self: Router): nil
---@field onReceive fun(self: Router,data: string): boolean
---@field onStart fun(self: Router): nil
---@field updatedConnectedRouters fun(self: Router): nil triggers an update chain for this router
---@field name string
---@field wrapper RouterWrapper 
---@field memory RouterMemory
---@param name string
---@return Router
function Router(name)
    local ret = {
        transmitionQueue = {},
        doTick = doTick,
        transmit = transmitMessage,
        onReceive = onReceive,
        onStart = onStart,
        updateConnectedRouters = updateConnectedRouters,
        name = name,
        wrapper = nil,
        memory = RouterMemory(),
        properties = {
            name = name,
            supports_endpoints = true,
            router_refresh_tick_max = 6000
        }
    }
    ret.memory.network_state = NetworkState(ret)
    return ret
end

return Router