---@class KnownEndpoint
---@field address string
---@field last_updated integer
---@field isActive fun(self: KnownEndpoint): boolean
---@field router Router

---@param router_memory RouterMemory
---@param network_name string
---@return KnownEndpoint
function KnownEndpoint(router_memory,network_name)
    ---@type KnownEndpoint
    return {
        address = network_name,
        last_updated = router_memory.router.current_time_milis,
        router = router_memory.router,
        isActive = function(self)
            return self.router.current_time_milis - self.last_updated <= self.router.configs.endpoint_unresponsive_milis
        end
    }
end