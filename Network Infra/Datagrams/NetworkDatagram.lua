Route = Route or require('Route')

NETWORK_DATAGRAM_PROT = NETWORK_DATAGRAM_PROT or {}

local function toString(self)
    return "[NDT-" .. self.time_to_die .. "-" ..
    "(" .. self.route ..")" ..
    "-" .. self.type .. -- Redundante
    "-(" .. self.message .. ")]"
end

local function getUpdated(self)
    if self.time_to_die > 0 then 
        return NetworkDatagram(
            self.content,
            self.route,
            self.type,
            self.routerObject,
            self.time_to_die - 1,
            self.updateFunction
        )
    else
        self:dieFunction()
        return nil
    end
end

--- @class NetworkDatagram
--- @field content string
--- @field route string talvez Route?
--- @field type string
--- @field routerObject Router
--- @field time_to_die integer
--- @field toString fun(param:self): string
--- @param content string
--- @param route string
--- @param type string
--- @param routerObject Router
--- @param time_to_die integer|nil
--- @return NetworkDatagram
function NetworkDatagram(content, route, type, routerObject, time_to_die)
    return {
        content = content,
        time_to_die = time_to_die or 90,
        route = route,
        type = type or "MSG_DATAGRAM",
        toString = toString,
        --- next = getNextRouter,
        routerObject = routerObject,
        getUpdated = getUpdated
    }
end

local function ParseDatagramComponents(data)
    local time_to_die, route_str, type, message = string.match(data,"%[NDT%-(%d+)%-%((.*)%)%-(%w+)%-%((.*)%)%]")
    if time_to_die == nil then
        return false
        --error("could not parse string for datagram:\n"..data)
    end
    time_to_die = tonumber(time_to_die)
    return time_to_die, route_str, type, message
end

local function onDie()
    -- TODO
end

local function onMessageReceived(data)
    local time_to_die, route_str, type, message = ParseDatagramComponents(data)
    if not time_to_die then return false end

    local route = Route(route_str)
    -- TODO
end

local network_parser = {
    onDie = onDie,
    onMessageReceived = onMessageReceived
}

table.insert(NETWORK_DATAGRAM_PROT,network_parser)

return NetworkDatagram