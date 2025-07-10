Router = Router or require('Router')

local function onTick(self)
    self.router:doTick() -- timekeeping maybe?
    self.iteration = self.iteration + 1
end

---@param self RouterWrapper
local function onMessageReceived(self,  event, side, channel, replyChannel, message, distance)
    self.router:onReceive(message)
end

local function nextEvent(self)
    local event, b, c, d, e, f, g = os.pullEvent()
    if event == 'alarm' then
        onTick(self)
    elseif event == 'modem_message' then
        onMessageReceived(self,event,b,c,d,e,f,g)
    end
end

local function transmitMessage(self, message)
    self.modem.transmit(self.channel,self.channel,message)
end

--- @param self RouterWrapper
local function begin(self,delay)
    delay = delay or 0.1
    self.router.wrapper = self
    self.router:onStart()
    self.modem.open(self.channel)
    
    local monitor = peripheral.find("monitor")
    if peripheral ~= nil then
        self.output_stream("Redirecting all output to connected monitor")
        term.redirect(monitor)
        monitor.setCursorPos(1,1)
        term.setCursorPos(1,1)
        term.clear()
    end
    self.output_stream("STARTING ROUTER " .. self.router.name .. " ON CHANNEL " .. self.channel)

    while self.should_be_running do
        os.setAlarm(delay)
        nextEvent(self)
    end

    self.output_stream("ENDED ROUTER " .. self.router.name)
end

---@class RouterWrapper
---@field transmitMessage fun(self: RouterWrapper, message: string)
---@field router Router
---@field begin fun(self: RouterWrapper)
---@field iteration integer
function RouterWrapper(router_object, channel, output_stream)
    local modem = peripheral.find("modem")
    local wrapper = {
        transmitMessage = transmitMessage,
        modem = modem,
        router = router_object,
        channel = channel,
        begin = begin,
        should_be_running = true,
        output_stream = output_stream or function(msg) print(msg) end,
        iteration = 0
    }
    
    router_object.wrapper = wrapper

    return wrapper
end

return RouterWrapper