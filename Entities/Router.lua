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

local function doTick(self, iteration)

end

local function onReceive(self, message)
    
end

local function onStart(self)
    self.table = {} -- god bless the garbage collector
end

function Router(name)
    return {
        transmitionQueue = {},
        doTick = doTick,
        transmit = transmitMessage,
        onReceive = onReceive,
        onStart = onStart,
        name = name,
        wrapper = nil,
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

function RouterInfo(name, dist, path)
    return {
        name = name, dist = dist, path = path,
        type = 'RouterInfo'
    }
end
