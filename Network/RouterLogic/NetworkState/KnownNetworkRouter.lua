---@class KnownNetworkRouter
---@field name string
---@field connections table<string,string>
---@field addConnection fun(self:KnownNetworkRouter,router:string): nil
---@field removeAllConnections fun(self:KnownNetworkRouter)
---@field isActive fun(self: KnownNetworkRouter, context: Router): boolean
---@field type 'KnownRouter'
---@field remote_last_update integer
---@field last_update integer

---@param name string
---@param remote_last_update integer
---@param current_time integer
---@param connections ?table<string,string>
---@return KnownNetworkRouter
function KnownNetworkRouter(name,connections,remote_last_update,current_time)
    local con = {}
    if connections then
        for key, value in pairs(connections) do
            con[key] = value
        end
    end

    ---@type KnownNetworkRouter
    return{
        name = name,
        connections = con,
        type = 'KnownRouter',
        remote_last_update = remote_last_update,
        last_update = current_time,
        addConnection = function (self,router_name)
            self.connections[router_name] = router_name
        end,
        removeAllConnections = function (self)
            for key, value in pairs(self.connections) do
                self.connections[key] = nil
            end
        end,
        isActive = function (self, context)
            return context.current_time_milis - self.last_update < context.configs.known_router_unresponsive_removal_milis
        end
    }
end