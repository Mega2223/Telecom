Graph = require('Graph')

---@class KnownEndpoint
function KnownEndpoint(parent_router, address)

end

---@class KnownConnection
function KnownConnection(to, weight)
    return {
        to = to,
        weight = weight,
        type = 'KnownConnection'
    }
end

---@class KnownRouter
function KnownRouter(name,connections)
    local con = {}
    local i = 1
    while connections ~= nil and connections[i] ~= nil do
        table.insert(con,connections[i])
        i = i + 1
    end
    return{
        name = name,
        connections = con,
        type = 'KnownRouter',
        addConnection = function (self,knownRouterObject)
            table.insert(self.connections,knownRouterObject)
        end
    }
end

---@class NetworkState
---@field routers table<integer,KnownRouter>
---@field connections table<integer, KnownConnection>
---@field endpoints table<integer, KnownEndpoint>
---@field addConnection fun(self: NetworkState, from_name: string, to_name: string, weight: number | nil, is_bidirectional: boolean | nil): nil
---@field getRouter fun(self: NetworkState, router_name: string): KnownRouter | nil
---@param router_object Router
---@return NetworkState
function NetworkState(router_object)
    return{
        routers = {},
        connections = {},
        endpoints = {},
        router = router_object,
        addConnection = function(self, from_name, to_name, weight, is_bidirectional)
            is_bidirectional = is_bidirectional or true
            local from = self:getRouter(from_name) or KnownRouter(from_name)
            local to = self:getRouter(to_name) or KnownRouter(to_name)
            from:addConnection(to); to:addConnection(from)
        end,
        getRouter = function(self,router_name)
            for router in self.routers do
                if router.name == router_name then
                    return router
                end
            end
            return nil
        end,
        type = 'NetworkState'
    }
end

return NetworkState