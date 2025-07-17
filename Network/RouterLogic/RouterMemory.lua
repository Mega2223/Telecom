require('Network.RouterLogic.NetworkState')

---@class RouterMemory
---@field iteration integer
---@field adjacent_routers table<integer | 'last_updated', string | integer>
---@field type string
---@field router Router
---@field network_state NetworkState
---@field updateAdjacencies fun(self: RouterMemory, adjacencies: table<integer, string>)

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

---Constructs an empty RouterMemory object
---@param router Router
---@return RouterMemory
function RouterMemory(router)
    local r = {
        iteration = 1,
        router = router,
        adjacent_routers = {
            last_updated = 0
        },
        network_state = NetworkState(router),
        type = 'RouterMemory',
        updateAdjacencies = updateAdjacencies
    }
    return r
end

return RouterMemory