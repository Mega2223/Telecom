require('NetworkState')

---@class RouterMemory
---@field iteration integer
---@field adjacent_routers table<integer, string>
---@field type string
---@field network_state NetworkState

---Constructs an empty RouterMemory object
---@return RouterMemory
function RouterMemory()
    return {
        iteration = 0,
        adjacent_routers = {},
        network_state = NetworkState(),
        type = 'RouterMemory'
    }
end

return RouterMemory