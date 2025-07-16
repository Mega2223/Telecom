NETWORK_DATAGRAM_PROT = NETWORK_DATAGRAM_PROT or {}

---@class ConnectionsDatagram
---@field time_to_die integer
---@field routers_traveled table<integer,string>
---@field routers_traveled_string string
---@field origin_name string
---@field connections table<integer,string>
---@field toString fun(self: ConnectionsDatagram): string

---[CDT-%TTD%-(%VISITED_ROUTERS%)-%ORIGIN_NAME%-(%ROUTER_KNOWN_CONNECTIONS%)]

---[CDT-%TTD%-(%VISITED_ROUTERS%)-%ORIGIN_NAME%-(%ROUTER_KNOWN_CONNECTIONS%)]
---[CDT-1-(ABC)-ORIGIN-(CONNECTIONS)]

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

---@param data string
---@return integer,string,string,string
local function parseConnectionsDatagram(data)
    local time_to_die, visited_routers, origin_name, connections = string.match(data,"%[CDT%-(%d+)%-%((.+)%)%-(.+)%-%((.+)%)]")
    return math.floor( tonumber(time_to_die) or 0 ), visited_routers, origin_name, connections
end

---converts a list of connections into a string that goes into the datagram string form
---@param data table<integer,string>
---@return string
local function connectionsToString(data)
    local ret = ""
    for i = 1, #data do
        ret = ret .. "(" .. data[i] .. ")"
    end
    return ret
end

---@param self ConnectionsDatagram
---@return string
local function toString(self)
    return "[CDT-" .. self.time_to_die ..
            "-(" .. self.routers_traveled_string ..
            ")-" .. self.origin_name .. 
            "-(" .. connectionsToString(self.connections) ..
            ")]"
end

---parses a connection datagram given from a string
---@param data string
---@return ConnectionsDatagram
function ParsedConnectionsDatagram(data)
    local time_to_die, visited_routers, origin_name, connections = parseConnectionsDatagram(data)
    return ConnectionsDatagram(time_to_die,visited_routers,origin_name,connections)
end

---ConnectionsDatagram constructor
---@param time_to_die integer
---@param visited_routers string
---@param origin_name string
---@param connections string
---@return ConnectionsDatagram
function ConnectionsDatagram(time_to_die, visited_routers, origin_name, connections)
    return {
        toString = toString,
        time_to_die = time_to_die,
        routers_traveled = parseVisitedRouters(visited_routers),
        routers_traveled_string = visited_routers,
        origin_name = origin_name,
        connections = parseConnections(connections)
    }
end

---@param msg string
---@param router Router
---@return boolean
local function onMessageReceived(msg, router)
    -- Action taken upon an router receiving this datagram
    -- Returns false if message does not parse into this type of datagram
    local time_to_die, visited_routers, origin_name, connections = parseConnectionsDatagram(msg)
    if time_to_die and visited_routers and origin_name and connections then
        local connections_datagram = ConnectionsDatagram(time_to_die,visited_routers,origin_name,connections)
        local is_already_visited = false

        for i = 1, #connections_datagram.connections do
            if connections_datagram.connections[i] == router.name then is_already_visited = true end
            router.memory.network_state:setRouterState(origin_name,parseVisitedRouters(visited_routers))
            --TODO eu parei aqui
        end

       

        if not is_already_visited then
            table.insert(connections_datagram.routers_traveled,router.name)
            router:transmit(connections_datagram:toString())
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
    type = 'ConnectionsDatagramParser'
}

table.insert(NETWORK_DATAGRAM_PROT,connections)

return ConnectionsDatagram