--- The connections datagram expresses some router and all it's adjacent routers
--- It is transmitted through the network via a tree broadcast algorithm

NETWORK_DATAGRAM_PROT = NETWORK_DATAGRAM_PROT or {}

---@class RouterPropertiesDatagram
--- Has the information of a given router's neighboring routers and its respective properties,
--- is sent through the network via a broadcast algorithm.
---@field time_to_die integer
---@field routers_traveled table<integer,string>
---@field origin_name string
---@field connections table<integer,string>
---@field toString fun(self: RouterPropertiesDatagram): string
---@field local_time integer
---@field properties table<string,string|integer>
---@field endpoints table<integer,string>

---[CDT-%TTD%-(%VISITED_ROUTERS%)-%ORIGIN_NAME%-(%ROUTER_KNOWN_CONNECTIONS%)-(%ENDPOINTS%)-[%TIME%]-(%PROPERTIES%)]
---[CDT-1-(ABC)-ORIGIN-(CONNECTIONS)-(ENDPOINTS)-[LOC_TIME]-(P1=(VAL);P2=(VAL); ... ))]

---parses router string into table
---@param data string
---@return table<integer,string>
local function parseVisitedRouters(data)
    local ret = {}
    for i in string.gmatch(data,"%((.-)%)") do
        table.insert(ret,i)
    end
    return ret
end

---parses connection list into table
---@param data string
---@return table<integer,string>
local function parseConnections(data)
    local ret = {}
    for i in string.gmatch(data,"%((.-)%)") do
        table.insert(ret,i)
    end
    return ret
end

---gets the parameters from the datagram's string form
---@param data string
---@return integer,string,string,string,string,integer,string
function parseRouterPropertiesDatagram(data)
    local time_to_die, visited_routers, origin_name, connections, endpoints, local_time, properties =
        string.match(data, "%[CDT%-(%d+)%-%((.+)%)%-(.+)%-%((.*)%)%-%((.*)%)%-%[(%d+)%]%-%((.*)%)%]")
    return math.floor( tonumber(time_to_die) or 0 ), visited_routers, origin_name, connections, endpoints, math.floor(tonumber(local_time) or -1), properties
end

---@param properties table<string,string|integer>
---@return string
local function propertiesToString(properties)
    -- P1=(VAL);P2=(VAL); ...
    local ret = ""
    for key, value in pairs(properties) do
        ret = ret .. string.format("%s=(%s);", key, tostring(value))
    end
    return ret
end

---@param property_string string
---@return table<string,string|integer>
local function stringToProperties(property_string)
    local ret = {}
    for key, value in string.gmatch(property_string, "([^;]+)=%(([^;]+)%);") do
        ret[key] = tonumber(value) or value
    end
    return ret
end

---@param self RouterPropertiesDatagram
---@return string
local function toString(self)
    print(
        self.time_to_die,
        listToString(self.routers_traveled),
        self.origin_name,
        listToString(self.connections),
        listToString(self.endpoints),
        self.local_time,
        propertiesToString(self.properties)
    )
    print('the fuck',self.endpoints,' ->tostr->',listToString(self.endpoints))
    return string.format("[CDT-%d-(%s)-%s-(%s)-(%s)-[%d]-(%s)]",
        self.time_to_die,
        listToString(self.routers_traveled),
        self.origin_name,
        listToString(self.connections),
        listToString(self.endpoints),
        self.local_time,
        propertiesToString(self.properties)
    )
end

---@param known_adjacencies table<string,KnownNeighbor>
---@return string
function compileConnectionsIntoString(known_adjacencies)
    local ret = ""
    for key, value in pairs(known_adjacencies) do
        ret = ret .. '(' .. key .. ')'
    end
    return ret
end

---RouterPropertiesDatagram constructor
---@param time_to_die integer
---@param visited_routers string
---@param origin_name string
---@param connections string
---@param endpoints string
---@param local_time integer
---@param properties ? string | table<string,string|integer>
---@return RouterPropertiesDatagram
function RouterPropertiesDatagram(time_to_die, visited_routers, origin_name, connections, endpoints, local_time, properties)
    if type(properties) == "string" then
        properties = stringToProperties(properties)
    end
    ---@type RouterPropertiesDatagram
    return {
        toString = toString,
        time_to_die = time_to_die,
        routers_traveled = parseVisitedRouters(visited_routers),
        origin_name = origin_name,
        connections = parseConnections(connections),
        endpoints = stringToList(endpoints) or {},
        local_time = local_time,
        properties = properties or {}
    }
end

---@param msg string
---@param router Router
---@return boolean
function onMessageReceived(msg, router)
    -- Action taken upon an router receiving this datagram
    -- Returns false if message does not parse into this type of datagram
    local time_to_die, visited_routers, origin_name, connections, endpoints, local_time, properties = parseRouterPropertiesDatagram(msg)
    if time_to_die and visited_routers and origin_name and connections and endpoints and properties then
        local connections_datagram = RouterPropertiesDatagram(time_to_die-1,visited_routers,origin_name,connections,endpoints,local_time,properties)
        local is_already_visited = false

        for i = 1, #connections_datagram.routers_traveled do
            if connections_datagram.routers_traveled[i] == router.name then
                is_already_visited = true
            end
            if local_time <= router.memory.network_state:getRouterSafe(origin_name).remote_last_update then
                is_already_visited = true
            end
        end

        if (not is_already_visited) and time_to_die > 0 then
            table.insert(connections_datagram.routers_traveled,router.name)
            router:transmit(connections_datagram:toString())
            router.memory.network_state:setRouterState(
                origin_name,
                parseConnections(connections),
                stringToList(endpoints) or {},
                router.current_time_milis,
                local_time,
                NetworkPath(parseVisitedRouters(visited_routers)):append(router.name):reverse()
            )
            for property, value in pairs(connections_datagram.properties) do
                router.memory.network_state:getRouter(origin_name).properties[property] = value
            end
        end

        return true
    else
        return false
    end
end

local function onDie()
    -- What to do in case the message dies in the net
end

---@type DatagramParser
local RouterPropertiesDatagramParser = {
    onDie = onDie,
    onMessageReceived = onMessageReceived,
    type = 'RouterPropertiesDatagramParser'
}

table.insert(NETWORK_DATAGRAM_PROT,RouterPropertiesDatagramParser)

return RouterPropertiesDatagram