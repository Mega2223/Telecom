NETWORK_DATAGRAM_PROT = NETWORK_DATAGRAM_PROT or {}

require('Network.RouterLogic.Datagrams.DiscoveryDatagram')
require('Network.RouterLogic.Datagrams.NetworkStateDatagram')
require('Network.RouterLogic.Datagrams.ConnectionsDatagram')

require('Network.RouterLogic.NetworkState.NetworkState')
require('Network.RouterLogic.RouterMemory.RouterMemory')
require('Network.RouterLogic.RouterConfig')
require('Network.RouterLogic.TransmitionQueue')

require('Utils.TaskManager.TaskManager')

---@class Router Describes a router entity, which must be bound to a Wrapper entity
---@field transmit fun(self: Router,data: string, time_from_now: integer | nil): boolean
---@field doTick fun(self: Router, time: integer): nil
---@field onReceive fun(self: Router,data: string): boolean
---@field onStart fun(self: Router): nil
---@field updateConnectedRouters fun(self: Router, time: integer) triggers an update chain for this router
---@field name string
---@field transmition_queue TransmitionQueue
---@field wrapper ModemWrapper 
---@field memory RouterMemory
---@field configs RouterConfig
---@field current_time_milis integer
---@field task_manager TaskManager

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
---@param time_milis integer
local function doTick(self, time_milis)
    self.memory.iteration = self.memory.iteration + 1
    self.current_time_milis = time_milis

    -- Atualiza as tarefas do TaskManager interno
    self.task_manager:doTick(time_milis)

    -- Se faz muito tempo que o roteador pingou os adjacentes, faça isso agora
    if time_milis - self.memory.last_adjacency_ping >= self.configs.adjacency_update_milis then
        self:updateConnectedRouters(time_milis)
    end

    -- Se não houve resposta de um roteador adjacente a muito tempo, o esqueça
    for router_name, known_neighbor in pairs(self.memory.adjacent_routers) do
        if time_milis - known_neighbor.last_updated >= self.configs.adjacency_unresponsive_removal_milis then
            print('EXCEEDED',time_milis,known_neighbor.last_updated,self.configs.adjacency_unresponsive_removal_milis)
            self.memory.adjacent_routers[router_name] = nil
        end
    end

    -- Remova da memória endpoints que não foram recebidos atualizações de status a muito tempo
    for endpoint_name, endpoint in pairs(self.memory.known_endpoints) do
        if not endpoint:isActive() then
            self.memory.known_endpoints[endpoint_name] = nil
        end
    end

    -- Mande o status desse roteador para os demais via broadcast
    if time_milis - self.memory.last_adjacency_broadcast >= self.configs.adjacency_broadcast_milis then
        local broadcast = ConnectionsDatagram( --RouterStatusDatagram?
            40,
            string.format("(%s)", self.configs.name),
            self.configs.name,
            compileConnectionsIntoString(self.memory.adjacent_routers), -- Eu a caminho de errar todos os jargons kkk
            self.current_time_milis
        )
        local success = self:transmit(broadcast:toString())
        if success then
            self.memory.last_adjacency_broadcast = time_milis
        end
        self.memory.network_state:updateSelf()
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
        current_time_milis = 0,
        task_manager = TaskManager()
    }
    ret.transmition_queue = TransmitionQueue(ret)
    ret.memory = RouterMemory(ret)
    return ret
end

return Router