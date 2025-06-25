function getTypeName(obj)
    local t = type(obj)
    if t == 'table' then
        return t['type'] or t
    else
        return t
    end
end

local function checkPendencies(self)

end

local function nextEvent(self)
    local event, a, b, c, d, e, f, g = os.pullEvent()
    if event == 'modem_message' then
        
    elseif event == '' then
        
    end
end

local function updateRouters(self)
    self:transmitMessage("RR-PING")
end

local function transmitMessage(self, msg)

end

local function doTick(self)

end

local function onReceive(self, message)
    if message == 'RR-PING' then
        self:transmitMessage('RR-REPLY-' .. self.name)
    end
end

local function start(self)
    monitor = peripheral.find("monitor")
    if peripheral ~= nil then
        print("redirecting all output to monitor")
        term.redirect(monitor)
    end
    print("STARTING ROUTER " .. self.name .. " ON CHANNEL " .. self.channel)
end

function Router(channel, modem_peripheral, wait_delay, name)
    return {
        channel = channel,
        transmitionQueue = {},
        doTick = doTick,
        transmit = transmitMessage,
        onReceive = onReceive,
        start = start,
        peripheral = modem_peripheral,
        wait_delay = wait_delay,
        name = name,
        memory = {
            adjacent_routers = {},
            awaiting_replies = {},
            network = {},
            endpoints = {}
        },
        properties = {
            name = name,
            supports_endpoints = true
        }
    }
end

function Datagram(msg, time_to_die)
    return {
        message = msg,
        time_to_die = time_to_die,
        type = 'Datagram'
    }
end

function GraphPath(routers)
    --routers.cl
    return {
        route = routers,
        type = 'GraphPath'
    }
end

function RouterInfo(name, dist, path)
    return {
        name = name, dist = dist, path = path,
        type = 'RouterInfo'
    }
end

function PendentMessage(isAnswer, doAnswerLogic, time_to_die)
    return {
        isAnswer = isAnswer, doAnswerLogic = doAnswerLogic, time_to_die = time_to_die,
        type = 'PendentMessage'
    }
end