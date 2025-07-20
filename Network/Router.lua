NETWORK_DATAGRAM_PROT = NETWORK_DATAGRAM_PROT or {}

require('Commons.Datagrams.DiscoveryDatagram')
require('Commons.Datagrams.NetworkStateDatagram')

require('Network.RouterLogic.NetworkState')
require('Network.RouterLogic.RouterMemory')
require('Network.RouterLogic.RouterConfig')
require('Network.RouterLogic.TransmitionQueue')

---@param self Router
---@param time integer
local function updateConnectedRouters(self, time)
    --self.memory:clearAdjacencies()
    self.memory.last_adjacency_ping = time
    local ask = DiscoveryDatagram(self.configs.name,'nil','ASK'..tostring(time))
    self:transmit(ask:toString())
    --self.memory.adjacent_routers.last_updated = time
end

--- @param self Router
--- @param msg string
--- @param time_from_now ?integer
local function transmitMessage(self, msg, time_from_now)
    --return self.wrapper:transmitMessage(msg)
    ---table.insert(self.transmition_queue,msg)
    self.transmition_queue:scheduleMessage(msg,self.current_time_milis + (time_from_now or 0))
end

---@param self Router
---@param time integer
local function doTick(self, time)
    self.memory.iteration = self.memory.iteration + 1
    self.current_time_milis = time
    if time - self.memory.last_adjacency_ping > self.configs.adjacency_update_milis then
        self:updateConnectedRouters(time)
    end
    self.transmition_queue:refresh(self.current_time_milis,1)
    --[[if self.transmition_queue[1] then
        if self.wrapper:transmitMessage(self.transmition_queue[1]) then
            table.remove(self.transmition_queue,1)
        end
    end]]
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
    ret.memory.network_state = NetworkState(ret)
    return ret
end

return Router