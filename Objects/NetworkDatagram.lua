local function getNextRouter(self)
    
end

local function toString(self)
    return "[NDT-" .. self.time_to_die .. "-" ..
    "(" .. self.route ..")" ..
    "-" .. self.type .. 
    "-(" .. self.message .. ")]"
end

local function update(self)
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

local function dieFunction(self)
    local router = self.routerObject
end

--- print(string.match("eu sou o 12-13-14 da silva","%d+%-%d+%-%d+"))
--- print(string.match("NDT-2-oi-(ocasci)","NDT%-(%d+)%-(%w+)%-%((.*)%)"))
--- 
function ParsedNetworkDatagram(data)
    local time_to_die, route, type, message = string.match(data,"%[NDT%-(%d+)%-%((.*)%)%-(%w+)%-%((.*)%)%]")
    if time_to_die == nil then
        error("could not parse string for datagram:\n"..data)
    end

end

function NetworkDatagram(content, route, type, routerObject, time_to_die, updateFunction, dieFunction)
    return {
        content = content,
        time_to_die = time_to_die or 90,
        route = route,
        type = type or "MSG_DATAGRAM",
        toString = toString,
        next = getNextRouter,
        routerObject = routerObject,
        getUpdated = updateFunction or update,
        onDie = dieFunction or dieFunction
    }
end

DatagramType = DatagramType or require('DatagramType')
return NetworkDatagram