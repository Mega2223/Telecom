require('Network.RouterLogic.ConnectionManager.KnownAdjacentRouter')
require('Utils.Graph')

---@class NetworkState
---@field protected routers table<string,KnownNetworkRouter>
---@diagnostic disable: invisible
---@field router Router
---@field getRouter fun(self: NetworkState, router_name: string,force_router: boolean | nil): KnownNetworkRouter | nil
---@field getRouterSafe fun(self: NetworkState, router_name: string): KnownNetworkRouter
---@field setRouterState fun(self: NetworkState, router_name: string, connections: table<integer,string>, time: integer, remote_time: integer): nil
---@field toString fun(self: NetworkState): string
---@field updateSelf fun(self: NetworkState)
---@field type "NetworkState"
---@param router_object Router
---@return NetworkState
function NetworkState(router_object)
    ---@type NetworkState
    return{
        routers = {},
        --connections = {},
        --endpoints = {},
        router = router_object,
        getRouter = function(self,router_name,force_router)
            if self.routers[router_name] then
                return self.routers[router_name]
            end
            if force_router then
                local router = KnownNetworkRouter(router_name,nil,-1000,router_object.current_time_milis)
                self.routers[router_name] = router
                return router
            end
            return nil
        end,
        getRouterSafe = function(self, router_name)
            ---@diagnostic disable-next-line: return-type-mismatch
            return self:getRouter(router_name,true)
        end,
        setRouterState = function(self, router_name, connections, time, remote_time)
            --print('con',connections[1])
            local router = self:getRouterSafe(router_name)
            router.last_update = time
            router.remote_last_update = remote_time
            router:removeAllConnections()
            
            for i = 1, #connections do
                if connections[i] ~= router_name then
                    router:addConnection(connections[i])
                end
            end
        end,
        updateSelf = function(self)
            local self_in_network = self:getRouterSafe(self.router.configs.name)
            self_in_network.last_update = self.router.current_time_milis
            self_in_network.remote_last_update = self.router.current_time_milis
            self_in_network:removeAllConnections()
            for key, value in pairs(self.router.memory.adjacent_routers) do
                self_in_network:addConnection(key)
            end
            for name, router in pairs(self.routers) do
                if not router:isActive(self.router) then
                    self.routers[name] = nil
                end
            end
        end,
        type = 'NetworkState',
        toString = function (self)
            local ret = 'routers = (\n'
            for name, router in pairs(self.routers) do
                local activity = 'INACTIVE'; if router:isActive(self.router) then activity = 'ACTIVE' end
                ret = ret .. '  router ' .. router.name ..' [' .. activity .. '] -> L('.. router.last_update ..') R(' .. router.remote_last_update ..') [ '
                for j, dest in pairs(router.connections) do
                    ret = ret .. dest .. ' '
                end
                ret = ret .. ']\n'
            end
            ret = ret .. ')\n'
            return ret
        end
    }
end

return NetworkState