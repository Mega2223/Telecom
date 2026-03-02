---@class EndpointLogic.Memory
---@field address ?string
---@field connected_router ?string
---@field last_ping integer
---@field transaction_id ?string for when the endpoint has no name
---@field nearby_routers table<string,EndpointLogic.NearbyRouter>

---@class EndpointLogic.NearbyRouter
---@field last_seen integer
---@field name string
---@field distance ?number

---@return EndpointLogic.Memory
function EndpointMemory()
    ---@type EndpointLogic.Memory
    return {
        last_ping = -1,
        nearby_routers = {}
    }
end