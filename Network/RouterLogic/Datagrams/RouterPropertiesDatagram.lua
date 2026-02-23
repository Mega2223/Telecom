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

---[CDT-%TTD%-(%VISITED_ROUTERS%)-%ORIGIN_NAME%-(%ROUTER_KNOWN_CONNECTIONS%)-[%TIME%]-(%PROPERTIES%)]
---[CDT-1-(ABC)-ORIGIN-(CONNECTIONS)-(P1=(VAL);P2=(VAL); ... ))]

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
---time_to_die, visited_routers, origin_name, connections, local_time, properties
---@param data string
---@return integer,string,string,string,integer,string
local function parseRouterPropertiesDatagram(data)
    ---[CDT-%TTD%-(%VISITED_ROUTERS%)-%ORIGIN_NAME%-(%ROUTER_KNOWN_CONNECTIONS%)-[%TIME%]-(%PROPERTIES%)]
    local time_to_die, visited_routers, origin_name, connections, local_time, properties =
        string.match(data, "%[CDT%-(%d+)%-%((.+)%)%-%[(.+)%]%-%((.*)%)%-%[(%d+)%]%-%((.+)%)%]")
    print("PROPS = ", properties)
    return math.floor( tonumber(time_to_die) or 0 ), visited_routers, origin_name, connections, math.floor(tonumber(local_time) or -1), properties
end

---converts a list of connections into a string that goes into the datagram string form
---@param data table<integer,string>
---@return string
local function listToString(data)
    local ret = ""
    for i = 1, #data do
        ret = ret .. "(" .. data[i] .. ")"
    end
    return ret
end

---@param properties table<string,string|integer>
---@return string
local function propertiesToString(properties)
    -- P1=(VAL) P2=(VAL) ...
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
    for key, value in string.gmatch(property_string, "(%w*)=%((%w*)%);") do
        ret[key] = tonumber(value) or value
    end
    return ret
end

---@param self RouterPropertiesDatagram
---@return string
local function toString(self)
    return "[CDT-" .. self.time_to_die ..
            "-(" .. listToString(self.routers_traveled) ..
            ")-[" .. self.origin_name .. 
            "]-(" .. listToString(self.connections) ..
            ")-[" .. self.local_time ..
            "]-(" .. propertiesToString(self.properties) ..
            ")]"
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
---@param local_time integer
---@param properties string
---@return RouterPropertiesDatagram
function RouterPropertiesDatagram(time_to_die, visited_routers, origin_name, connections, local_time, properties)
    ---@type RouterPropertiesDatagram
    return {
        toString = toString,
        time_to_die = time_to_die,
        routers_traveled = parseVisitedRouters(visited_routers),
        origin_name = origin_name,
        connections = parseConnections(connections),
        local_time = local_time,
        properties = stringToProperties(properties)
    }
end

---@param msg string
---@param router Router
---@return boolean
local function onMessageReceived(msg, router)
    -- Action taken upon an router receiving this datagram
    -- Returns false if message does not parse into this type of datagram
    local time_to_die, visited_routers, origin_name, connections, local_time, properties = parseRouterPropertiesDatagram(msg)
    if time_to_die and visited_routers and origin_name and connections then
        local connections_datagram = RouterPropertiesDatagram(time_to_die-1,visited_routers,origin_name,connections,local_time,properties)
        local is_already_visited = false

        for i = 1, #connections_datagram.routers_traveled do
            if connections_datagram.routers_traveled[i] == router.name then is_already_visited = true end
            if local_time <= router.memory.network_state:getRouterSafe(origin_name).remote_last_update then is_already_visited = true end
        end

        if (not is_already_visited) and time_to_die > 0 then
            table.insert(connections_datagram.routers_traveled,router.name)
            router:transmit(connections_datagram:toString())
            --print(connections,'->',parseVisitedRouters(connections)[1])
            router.memory.network_state:setRouterState(
                origin_name,
                parseVisitedRouters(connections),
                router.current_time_milis,
                local_time
            )
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
local connections = {
    onDie = onDie,
    onMessageReceived = onMessageReceived,
    type = 'RouterPropertiesDatagramParser'
}

table.insert(NETWORK_DATAGRAM_PROT,connections)

return RouterPropertiesDatagram