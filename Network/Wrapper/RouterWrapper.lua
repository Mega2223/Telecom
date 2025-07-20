require('Network.Router')
---@todo debugwrapper :3
---@param self RouterWrapper
local function onTick(self)
    self.router:doTick(os.epoch()) -- timekeeping maybe?
    self.iteration = self.iteration + 1
    if self.iteration % 1000 ~= 0 then return end
    term.setCursorPos(1,1)
    term.clear()
    term.write('NAME ' .. self.router.configs.name .. '\n')
    term.setCursorPos(1,2)
    term.write('TIMER ' .. self.router.current_time_milis .. '\n')
    term.setCursorPos(1,3)
    term.write('NEXT_REFRESH '.. (
        self.router.current_time_milis -
        self.router.memory.last_adjacency_ping - 
        self.router.configs.adjacency_update_milis
    ) .. '\n')
    term.setCursorPos(1,4)
    local pretty = require('cc.pretty')
    term.write('ADJACENCIES:\n')
    pretty.pretty_print(self.router.memory.adjacent_routers)
end

---@param self RouterWrapper
local function onMessageReceived(self,  event, side, channel, replyChannel, message, distance)
    if self.router:onReceive(message) then
        print('PROCESSED')
        print(message)
        --self.router:transmit('AAAAAAAAHH')
    end
end

local function nextEvent(self,delay)
    local event, b, c, d, e, f = os.pullEvent()
    if event == 'timer' then
        onTick(self)
        os.startTimer(delay)
    elseif event == 'modem_message' then
        onMessageReceived(self,event,b,c,d,e,f)
    end
end

---@param self RouterWrapper
---@param message string
---@param milis_from_now ?integer
---@return boolean
local function transmitMessage(self, message, milis_from_now)
    milis_from_now = milis_from_now or 0
    local time = os.epoch()
    if time - self.last_transmition > 500 then
        self.modem.transmit(self.channel,self.channel,message)
        return true
    end
    return false
end

--- @param self RouterWrapper
local function begin(self,delay)
    delay = delay or 0.5
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
        os.startTimer(delay)
        nextEvent(self,delay)
    end

    self.output_stream("ENDED ROUTER " .. self.router.name)
end

---@class RouterWrapper
---@field transmitMessage fun(self: RouterWrapper, message: string): boolean
---@field router Router
---@field begin fun(self: RouterWrapper)
---@field iteration integer
---@field last_transmition integer

---Creates a RouterWrapper object
---@param router_object Router
---@param channel integer | nil
---@param output_stream fun(string) | nil
---@return RouterWrapper
function RouterWrapper(router_object, channel, output_stream)
    local modem = peripheral.find("modem")
    ---@type RouterWrapper
    local wrapper = {
        transmitMessage = transmitMessage,
        modem = modem,
        router = router_object,
        channel = channel or 1,
        begin = begin,
        should_be_running = true,
        output_stream = output_stream or function(msg) print(msg) end,
        iteration = 1,
        last_transmition = 1
    }
    
    router_object.wrapper = wrapper

    return wrapper
end

return RouterWrapper