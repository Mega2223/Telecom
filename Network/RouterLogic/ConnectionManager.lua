-- The connection manager manages connections with endpoints

---@class KnownEndpoint
---@field name string
---@field last_updated integer

---@class ConnectionManager
---@field endpoints table<string,KnownEndpoint>
---@field update fun(self:ConnectionManager, time_milis: integer)
---@field router Router

---@param time_milis integer
---@param self ConnectionManager
local function update(self, time_milis)
    for endpoint_name, endpoint in pairs(self.endpoints) do
        if endpoint.last_updated < time_milis - self.router.configs.endpoint_unresponsive_milis then
            self.endpoints[endpoint_name] = nil
        end
    end
end

---creates a connection manager
---@param router Router
---@return ConnectionManager
function ConnectionManager(router)
    ---@type ConnectionManager
    return {
        router = router,
        endpoints = {},
        update = update
    }
end

