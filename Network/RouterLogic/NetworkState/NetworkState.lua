require('Network.RouterLogic.NetworkState.KnownNetworkRouter')
require('Network.RouterLogic.NetworkState.NetworkPath')

---@class NetworkState
---@field network_routers table<string,KnownNetworkRouter>
---@field router Router
---@field getRouter fun(self: NetworkState, router_name: string,force_router: boolean | nil): KnownNetworkRouter | nil
---@field getRouterSafe fun(self: NetworkState, router_name: string): KnownNetworkRouter
---@field setRouterState fun(self: NetworkState, router_name: string, connections: table<integer,string>, endpoints: table<integer,string>, time: integer, remote_time: integer, path: nil | NetworkPath): nil
---@field toString fun(self: NetworkState): string
---@field updateSelf fun(self: NetworkState)
---@field getEndpointsMatchingPattern fun(self: NetworkState, pattern: string): table<integer, NetworkEndpoint>
---@field getEndpointWithName fun(self: NetworkState, name: string): NetworkEndpoint | nil
---@field type "NetworkState"

---@param router_object Router
---@return NetworkState
function NetworkState(router_object)
    ---@type NetworkState
    return{
        network_routers = {},
        router = router_object,
        getRouter = function(self,router_name,force_router)
            if self.network_routers[router_name] then
                return self.network_routers[router_name]
            end
            if force_router then
                local router = KnownNetworkRouter(router_name,nil,-1000,router_object.current_time_milis)
                self.network_routers[router_name] = router
                return router
            end
            return nil
        end,
        getRouterSafe = function(self, router_name)
            ---@diagnostic disable-next-line: return-type-mismatch
            return self:getRouter(router_name,true)
        end,
        setRouterState = function(self, router_name, connections, endpoints, time, remote_time, path)
            local router = self:getRouterSafe(router_name)
            router.last_update = time
            router.remote_last_update = remote_time
            router:removeAllConnections()
            router:clearEndpoints()
            
            for i = 1, #connections do
                if connections[i] ~= router_name then
                    router:addConnection(connections[i])
                end
            end

            for i = 1, #endpoints do
                router.connected_endpoints[i] = endpoints[i]
            end

            if path then
                router.path_to = path
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
            for name, router in pairs(self.network_routers) do
                if not router:isActive(self.router) then
                    self.network_routers[name] = nil
                end
            end
        end,
        type = 'NetworkState',
        toString = function (self) -- FIXME que horror
            local ret = 'routers = (\n'
            for name, router in pairs(self.network_routers) do
                local activity = 'INACTIVE'; if router:isActive(self.router) then activity = 'ACTIVE' end
                ret = ret .. '  router ' .. router.name ..' [' .. activity .. '] -> L('.. router.last_update ..') R(' .. router.remote_last_update ..') [ '
                for j, dest in pairs(router.connections) do
                    ret = ret .. dest .. ' '
                end
                ret = ret .. ']\n'
            end
            ret = ret .. ')\n'
            return ret
        end,
        getEndpointWithName = function (self,address)
            for net_router_name, network_router in pairs(self.network_routers) do
                for net_ep_name, network_endpoint in pairs(network_router.connected_endpoints) do 
                    if network_endpoint.address == address then
                        return network_endpoint
                    end
                end
            end
            return nil
        end,
        getEndpointsMatchingPattern = function(self, pattern)
            ---@type table<integer,NetworkEndpoint>
            local ret = {}
            for net_router_name, network_router in pairs(self.network_routers) do
                for net_ep_name, network_endpoint in pairs(network_router.connected_endpoints) do 
                    if string.match(net_ep_name, pattern) then
                       table.insert(ret,network_endpoint)
                    end
                end
            end
            return ret
        end
    }
end

return NetworkState