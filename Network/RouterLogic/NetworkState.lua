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
---@field connections table<string,string>
---@field addConnection fun(self:KnownRouter,router:string): nil
---@field removeAllConnections fun(self:KnownRouter)
---@field isActive fun(self: KnownRouter, context: Router): boolean
---@field type 'KnownRouter'
---@field remote_last_update integer
---@field last_update integer
---@param name string
---@param remote_last_update integer
---@param current_time integer
---@param connections ?table<string,string>
function KnownRouter(name,connections,remote_last_update,current_time)
    local con = {}
    if connections then
        for key, value in pairs(connections) do
            con[key] = value
        end
    end

    ---@type KnownRouter
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
            return context.current_time_milis - self.last_update >= context.configs.known_router_unresponsive_removal_milis
        end
    }
end

---@class NetworkState
---@field routers table<integer,KnownRouter>
---@field router Router
-- ---@field endpoints table<integer, KnownEndpoint>
---@field getRouter fun(self: NetworkState, router_name: string,force_router: boolean | nil): KnownRouter | nil
---@field getRouterSafe fun(self: NetworkState, router_name: string): KnownRouter
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
            for i = 1, #self.routers do
                local router = self.routers[i]
                if router.name == router_name then
                    return router
                end
            end
            if force_router then
                local router = KnownRouter(router_name,nil,-1000,router_object.current_time_milis)
                table.insert(self.routers,router)
                return router
            end
            return nil
        end,
        getRouterSafe = function(self, router_name)
            ---@diagnostic disable-next-line: return-type-mismatch
            return self:getRouter(router_name,true)
        end,
        setRouterState = function(self, router_name, connections, time, remote_time)
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
        end,
        type = 'NetworkState',
        toString = function (self)
            local ret = 'routers = (\n'
            for i, router in pairs(self.routers) do
                local activity = 'INACTIVE'; if router:isActive(self.router) then activity = 'ACTIVE' end
                ret = ret .. '  router ' .. router.name ..' [' .. activity .. '] -> L('.. router.last_update ..') R(' .. router.remote_last_update ..') [ '
                for j, dest in(router.connections) do
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