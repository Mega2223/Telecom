require('Network.RouterLogic.NetworkState')

---@class RouterMemory
---@field iteration integer
---@field adjacent_routers table<string, KnownNeighbor>
---@field known_endpoints table<string, KnownEndpoint>
---@field type string
---@field router Router
---@field network_state NetworkState
---@field updateAdjacecy fun(self: RouterMemory, name: string, time_milis: integer)
---@field clearAdjacencies fun(self: RouterMemory)
---@field toString fun(self: RouterMemory): string
---@field last_adjacency_ping integer
---@field last_adjacency_broadcast integer
---@field connection_manager ConnectionManager

--[[
---@class KnownEndpoint
---@field address string
---@field last_updated integer
---@field isActive fun(self: KnownEndpoint): boolean
---@field router Router


---@param self RouterMemory
---@param address string
---@return KnownEndpoint
function KnownEndpoint(self,address)
    ---@type KnownEndpoint
    return {
        address = address,
        last_updated = self.router.current_time_milis,
        router = self.router,
        isActive = function(self)
            return self.router.current_time_milis - self.last_updated <= self.router.configs.endpoint_unresponsive_milis
        end
    }
end]]

---@class KnownNeighbor
---@field last_updated integer
---@field name string

---@param name string
---@param last_updated integer
---@return KnownNeighbor
function KnownNeighbor(name, last_updated)
    ---@type KnownNeighbor
    return {
        name = name,
        last_updated = last_updated
    }
end

---Converts object to string
---@param self RouterMemory
---@return string
local function toString(self)
    local ret = 'ROUTER_OBJ ' .. self.router.configs.name .. ':\n'
    ret = ret .. 'NETWORK = (\n' .. self.network_state:toString() .. ')\n'
    ret = ret .. 'ADJACENCIES'.. '(last_updated = ' .. self.last_adjacency_ping ..') = (\n' 
    for name, router in pairs(self.adjacent_routers) do
        ret = ret .. name .. ' '
    end
    ret = ret .. ')\nENDPOINTS = ('
    for name, endpoint in pairs(self.known_endpoints) do
        ret = ret .. name .. ' ' 
    end
    ret = ret .. ')\n'
    return ret
end

---Constructs an empty RouterMemory object
---@param router Router
---@return RouterMemory
function RouterMemory(router)
    ---@type RouterMemory
    local r = {
        iteration = 1,
        router = router,
        adjacent_routers = {},
        known_endpoints = {},
        last_adjacency_ping = 0,
        last_adjacency_broadcast = 0,
        network_state = NetworkState(router),
        connection_manager = ConnectionManager(router),
        type = 'RouterMemory',
        clearAdjacencies = function(self)
            local n = #self.adjacent_routers
            for i = 1, n do
                self.adjacent_routers[i] = nil
            end
        end,
        updateAdjacecy = function (self, name, time)
            local r = self.adjacent_routers[name] or KnownNeighbor(name,time)
            r.last_updated = time
            self.adjacent_routers[name] = r
        end,
        toString = toString
    }
    return r
end

return RouterMemory