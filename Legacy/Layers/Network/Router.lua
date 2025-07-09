RequiredAnswer = RequiredAnswer or require('Objects.RouterLogic.RequiredAnswer')

local function workPendencies(self)
    
end

local function updateConnectedRouters(self)
    self.wrapper:transmitMessage("RR-PING")
end

local function mapWeb(self)

end

local function transmitMessage(self, msg)
    self.wrapper:transmitMessage(msg)
end

local function doTick(self)
    self.memory.iteration = self.memory.iteration + 1
end

local function onReceive(self, message)
    local datagram = ParsedDatagram(message)
end

local function onStart(self)
    self.table = {} -- god bless the garbage collector
end

function Router(name)
    local ret = {
        transmitionQueue = {},
        doTick = doTick,
        transmit = transmitMessage,
        onReceive = onReceive,
        onStart = onStart,
        name = name,
        wrapper = nil,
        memory = {
            iteration = 0,
            adjacent_routers = {},
            awaiting_replies = {},
            network_state = nil,
        },
        properties = {
            name = name,
            supports_endpoints = true,
            router_refresh_tick_max = 6000
        }
    }
    ret.memory.network_state = NetworkState(ret)
    return ret
end

