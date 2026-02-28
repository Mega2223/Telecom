---@class EndpointLogic.Memory
---@field address ?string
---@field connected_router ?string
---@field last_ping integer
---@field transaction_id ?string for when the endpoint has no name

---@return EndpointLogic.Memory
function EndpointMemory()
    ---@type EndpointLogic.Memory
    return {
        last_ping = -1
    }
end