require('Network.RouterLogic.NetworkState')

---@class RouterMemory
---@field iteration integer
---@field adjacent_routers table<integer | 'last_updated', string | integer>
---@field type string
---@field router Router
---@field network_state NetworkState
---@field updateAdjacencies fun(self: RouterMemory, adjacencies: table<integer, string>)
---@field toString fun(self: RouterMemory): string

---@param self RouterMemory
---@param adjacencies table<integer, string>
local function updateAdjacencies(self, adjacencies)
    self.adjacent_routers = {
        last_updated = os.epoch()
    }
    for i = 1, #adjacencies do
        table.insert(self.adjacent_routers,adjacencies[i])
    end
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
        adjacent_routers = {
            last_updated = 0
        },
        network_state = NetworkState(router),
        type = 'RouterMemory',
        updateAdjacencies = updateAdjacencies,
        toString = toString
    }
    return r
end

return RouterMemory