require('NetworkState')

---@class RouterMemory
---@field iteration integer
---@field adjacent_routers table<integer, string>
---@field type string
---@field router Router
---@field network_state NetworkState

---Constructs an empty RouterMemory object
---@param router Router
---@return RouterMemory
function RouterMemory(router)
    return {
        iteration = 0,
        router = router,
        adjacent_routers = {},
        network_state = NetworkState(router),
        type = 'RouterMemory'
    }
end

return RouterMemory