NETWORK_DATAGRAM_PROT = NETWORK_DATAGRAM_PROT or {}

require('Commons.Datagrams.DiscoveryDatagram')
require('Network.RouterLogic.NetworkState')
require('Network.RouterLogic.RouterMemory')
require('Network.RouterLogic.RouterConfig')

---@param self Router
---@param time integer
local function updateConnectedRouters(self, time)
    local ask = DiscoveryDatagram(1,false,self.configs.name)
    self:transmit(ask:toString())
    self.memory.adjacent_routers.last_updated = time
end

--- @param self Router
--- @param msg string
local function transmitMessage(self, msg)
    return self.wrapper:transmitMessage(msg)
end

---@param self Router
---@param time integer
local function doTick(self, time)
    self.memory.iteration = self.memory.iteration + 1
    if time - self.memory.adjacent_routers.last_updated > self.configs.adjacency_update_milis then
        self:updateConnectedRouters(time)
    end
end

---@param self Router
---@param message string
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

---@param self Router
local function onStart(self)
    --self:updateConnectedRouters()
end

---@class Router Describes a router entity, which must be bound to a Wrapper entity
---@field transmit fun(self: Router,data: string): boolean
---@field doTick fun(self: Router, time: integer): nil
---@field onReceive fun(self: Router,data: string): boolean
---@field onStart fun(self: Router): nil
---@field updateConnectedRouters fun(self: Router, time: integer) triggers an update chain for this router
---@field name string
---@field wrapper RouterWrapper 
---@field memory RouterMemory
---@field configs RouterConfig
---@param configs table | nil
---@return Router
function Router(configs)
    local configs = RouterConfig(configs or {})
    assert(type(configs) == "table","invalid parameter for router constructor: " .. tostring(configs))
    local ret = {
        transmitionQueue = {},
        doTick = doTick,
        transmit = transmitMessage,
        onReceive = onReceive,
        onStart = onStart,
        updateConnectedRouters = updateConnectedRouters,
        name = configs.name,
        wrapper = nil,
        memory = nil,
        configs = configs
    }
    ret.memory = RouterMemory(ret)
    ret.memory.network_state = NetworkState(ret)
    return ret
end

return Router