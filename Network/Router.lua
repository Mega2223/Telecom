NETWORK_DATAGRAM_PROT = NETWORK_DATAGRAM_PROT or {}

require('Commons.Datagrams.DiscoveryDatagram')
require('Commons.Datagrams.NetworkStateDatagram')
require('Commons.Datagrams.ConnectionsDatagram')

require('Network.RouterLogic.NetworkState')
require('Network.RouterLogic.RouterMemory')
require('Network.RouterLogic.RouterConfig')
require('Network.RouterLogic.TransmitionQueue')

---@param self Router
---@param time integer
local function updateConnectedRouters(self, time)
    self.memory.last_adjacency_ping = time
    local ask = DiscoveryDatagram(self.configs.name,'nil','ASK'..tostring(time))
    self:transmit(ask:toString())
end

--- @param self Router
--- @param msg string
--- @param time_from_now ?integer
--- @return boolean
local function transmitMessage(self, msg, time_from_now)
    --return self.wrapper:transmitMessage(msg)
    ---table.insert(self.transmition_queue,msg)
    self.transmition_queue:scheduleMessage(msg,self.current_time_milis + (time_from_now or 0))
    return true
end

---@param self Router
---@param time integer
local function doTick(self, time)
    self.memory.iteration = self.memory.iteration + 1
    self.current_time_milis = time

    if time - self.memory.last_adjacency_ping >= self.configs.adjacency_update_milis then
        self:updateConnectedRouters(time)
    end

    for router_name, known_neighbor in pairs(self.memory.adjacent_routers) do
        if time - known_neighbor.last_updated >= self.configs.adjacency_unresponsive_removal_milis then
            print('EXCEEDED',time,known_neighbor.last_updated,self.configs.adjacency_unresponsive_removal_milis)
            self.memory.adjacent_routers[router_name] = nil
        end
    end

    if time - self.memory.last_adjacency_broadcast >= self.configs.adjacency_broadcast_milis then
        local broadcast = ConnectionsDatagram(
            40,
            string.format("(%s)", self.configs.name),
            self.configs.name,
            compileConnectionsIntoString(self.memory.adjacent_routers),
            self.current_time_milis
        )
        local success = self:transmit(broadcast:toString())
        if success then
            self.memory.last_adjacency_broadcast = time
        end
        self.memory.network_state:updateSelf()
    end

    for key, value in pairs(self.memory.network_state.routers) do
        if not value:isActive(self) then
            self.memory.network_state.routers[key] = nil
        end
    end

    self.transmition_queue:refresh(self.current_time_milis,1)
end

---@param self Router
---@param message string
local function onReceive(self, message)
    local datagram = message
    for i = 1, #NETWORK_DATAGRAM_PROT do
        local k = NETWORK_DATAGRAM_PROT[i]
        if k.onMessageReceived(datagram,self) then 
            return true
        end
    end
    print(self.name .. ' could not find fitting template for message:\n' .. message )
    return false
end

---@param self Router
local function onStart(self)
    --self:updateConnectedRouters()
end

---@class Router Describes a router entity, which must be bound to a Wrapper entity
---@field transmit fun(self: Router,data: string, time_from_now: integer | nil): boolean
---@field doTick fun(self: Router, time: integer): nil
---@field onReceive fun(self: Router,data: string): boolean
---@field onStart fun(self: Router): nil
---@field updateConnectedRouters fun(self: Router, time: integer) triggers an update chain for this router
---@field name string
---@field transmition_queue TransmitionQueue
---@field wrapper RouterWrapper 
---@field memory RouterMemory
---@field configs RouterConfig
---@field current_time_milis integer
---@param configs ?table
---@return Router
function Router(configs)
    local configs = RouterConfig(configs or {})
    --assert(type(configs) == "table","invalid parameter for router constructor: " .. tostring(configs))
    ---@type Router
    local ret = {
        doTick = doTick,
        transmit = transmitMessage,
        onReceive = onReceive,
        onStart = onStart,
        updateConnectedRouters = updateConnectedRouters,
        name = configs.name,
        ---@diagnostic disable-next-line: assign-type-mismatch
        wrapper = nil,
        ---@diagnostic disable-next-line: assign-type-mismatch
        memory = nil,
        ---@diagnostic disable-next-line: assign-type-mismatch
        transmition_queue = nil,
        configs = configs,
        current_time_milis = 0
    }
    ret.transmition_queue = TransmitionQueue(ret)
    ret.memory = RouterMemory(ret)
    return ret
end

return Router