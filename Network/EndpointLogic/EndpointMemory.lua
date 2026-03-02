---@class EndpointLogic.Memory
---@field address ?string
---@field connected_router ?string
---@field favorite_to_connect ?string
---@field last_ping integer
---@field last_router_request integer
---@field known_network_endpoints table<string,EndpointLogic.KnownEndpoint>
---@field transaction_id ?string for when the endpoint has no name
---@field nearby_routers table<string,EndpointLogic.NearbyRouter>

---@class EndpointLogic.NearbyRouter
---@field last_seen integer
---@field name string
---@field distance ?number

---@class EndpointLogic.KnownEndpoint
---@field last_update integer
---@field address string

---@param address string
---@param last_update integer
---@return EndpointLogic.KnownEndpoint
function EndpointMemoryKnownEndpoint(address, last_update)
    ---@type EndpointLogic.KnownEndpoint
    return {
        address = address, last_update = last_update
    }
end

---@return EndpointLogic.Memory
function EndpointMemory()
    ---@type EndpointLogic.Memory
    return {
        last_ping = -1,
        last_router_request = -1,
        nearby_routers = {},
        known_network_endpoints = {}
    }
end