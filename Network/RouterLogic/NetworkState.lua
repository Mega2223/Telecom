require('Utils.Graph')

--[[
---@ class KnownEndpoint
function KnownEndpoint(parent_router, address)

end

---@ class KnownConnection
function KnownConnection(to, weight)
    return {
        to = to,
        weight = weight,
        type = 'KnownConnection'
    }
end
]]

---@class KnownRouter
---@field name string
---@field connections table<integer,KnownRouter>
---@field addConnection fun(self:KnownRouter,router:KnownRouter): nil
---@field removeAllConnections fun(self:KnownRouter)
---@field type 'KnownRouter'
---@param name string
---@param connections table<integer,KnownRouter>|nil
function KnownRouter(name,connections)
    local con = {}
    local i = 1
    while connections ~= nil and connections[i] ~= nil do
        table.insert(con,connections[i])
        i = i + 1
    end
    ---@type KnownRouter
    return{
        name = name,
        connections = con,
        type = 'KnownRouter',
        addConnection = function (self,knownRouterObject)
            table.insert(self.connections,knownRouterObject)
        end,
        removeAllConnections = function (self)
            for i = 1, #self.connections do
                self.connections[i] = nil
            end
        end
    }
end

---@class NetworkState
---@field routers table<integer,KnownRouter>
-- ---@field endpoints table<integer, KnownEndpoint>
---@field getRouter fun(self: NetworkState, router_name: string,force_router: boolean | nil): KnownRouter | nil
---@field getRouterSafe fun(self: NetworkState, router_name: string): KnownRouter
---@field setRouterState fun(self: NetworkState, router_name: string, connections: table<integer,string>): nil
---@field toString fun(self: NetworkState): string
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
            for router in self.routers do
                if router.name == router_name then
                    return router
                end
            end
            if force_router then
                local router = KnownRouter(router_name)
                table.insert(self.routers,router)
                return router
            end
            return nil
        end,
        getRouterSafe = function(self, router_name)
            ---@diagnostic disable-next-line: return-type-mismatch
            return self:getRouter(router_name,true)
        end,
        ---@param self NetworkState
        ---@param router_name string
        ---@param connections table<integer, string>
        setRouterState = function(self, router_name, connections)
            ---@type KnownRouter
            local router = self:getRouterSafe(router_name)
            router:removeAllConnections()
            for i = 1, #connections do
                router:addConnection(
                    self:getRouterSafe(connections[i])
                )
            end
        end,
        type = 'NetworkState',
        toString = function (self)
            local ret = 'routers=(\n'
            for i =1, #self.routers do
                local router = self.routers[i]
                ret = ret .. 'router ' .. router.name .. ' -> [ '
                for j =1, #router.connections do
                    ret = ret .. router.connections[j].name .. ' '
                end
                ret = ret .. ']\n'
            end
            ret = ret .. ')\n'
            return ret
        end
    }
end

return NetworkState