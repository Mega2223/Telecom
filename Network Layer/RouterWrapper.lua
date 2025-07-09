Router = Router or require('Router')

local function onTick(self)
    self.router:doTick() -- timekeeping maybe?
    self.iteration = self.iteration + 1
end

local function onMessageReceived(self, event, side, channel, replyChannel, message, distance)
    self.router:onReceive(message)
end

local function nextEvent(self)
    local event, b, c, d, e, f, g = os.pullEvent()
    if event == 'alarm' then
        onTick(self)
    elseif event == 'modem_message' then
        onMessageReceived(self,b,c,d,e,f,g)
    end
end

local function transmitMessage(self, message)
    self.modem.transmit(self.channel,self.channel,message)
end

local function begin(self,delay)
    delay = delay or 0.1
    self.router:onStart()
    
    local monitor = peripheral.find("monitor")
    if peripheral ~= nil then
        self.output_stream("Redirecting all output to connected monitor")
        term.redirect(monitor)
    end
    self.output_stream("STARTING ROUTER " .. self.router.name .. " ON CHANNEL " .. self.channel)

    while self.should_be_running do
        os.setAlarm(delay)
        nextEvent(self)
    end

    self.output_stream("ENDED ROUTER " .. self.router.name)
end

function RouterWrapper(router_object, channel, output_stream)
    local modem = peripheral.find("modem")
    modem.open(channel)
    
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

function RouterWrapperSetup()
    return RouterWrapper(
        Router("RT-"..math.random(10000), 223, nil)
    )
end

return RouterWrapper