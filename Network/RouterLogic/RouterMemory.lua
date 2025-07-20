require('Network.RouterLogic.NetworkState')

---@class RouterMemory
---@field iteration integer
---@field adjacent_routers table<string, KnownNeighbor>
---@field type string
---@field router Router
---@field network_state NetworkState
---@field updateAdjacecy fun(self: RouterMemory, name: string, time_milis: integer)
---@field clearAdjacencies fun(self: RouterMemory)
---@field toString fun(self: RouterMemory): string
---@field last_adjacency_ping integer

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
    ret = ret .. 'ADJACENCIES'.. '(last_updated = ' .. self.adjacent_routers.last_updated ..') = (\n' 
    for i = 1, #self.adjacent_routers do
        ret = ret .. self.adjacent_routers[i] .. ' '
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
        last_adjacency_ping = 0,
        network_state = NetworkState(router),
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