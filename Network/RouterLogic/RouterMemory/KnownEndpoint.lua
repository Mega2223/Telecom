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
end