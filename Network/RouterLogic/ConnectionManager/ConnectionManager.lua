-- The connection manager manages connections with adjacent routers
require('KnownAdjacentRouter')

---@class ConnectionManager Managers connections between adjacent routers
---@field endpoints table<string,KnownAdjacentRouter>
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

