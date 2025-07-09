Graph = Graph or require('Graph')
if not Graph then error('Graph constructor not found') end

function KnownConnection(to, weight)
    return {
        to = to,
        weight = weight,
        type = 'KnownConnection'
    }
end

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