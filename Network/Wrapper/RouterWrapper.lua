require('Network.Router')
---@todo debugwrapper :3

last_render = 0

---@param self RouterWrapper
local function onTick(self)
    local time = math.floor(1000*os.clock())
    self.router:doTick(time) -- timekeeping maybe?
    self.iteration = self.iteration + 1

    if time - last_render < 1000 * .5 then return end
    last_render = time
    term.clear()

    local s = self.router.memory.network_state:toString()
    local x,y = term.getSize()
    term.setCursorPos(1,y/2)
    print(s)
    term.setCursorPos(1,2)
    term.write('NAME ' .. self.router.configs.name .. '\n')
    term.setCursorPos(1,3)
    term.write('TIMER ' .. self.router.current_time_milis .. '\n')
    term.setCursorPos(1,4)
    term.write('NEXT_REFRESH '.. (
        self.router.current_time_milis -
        self.router.memory.last_adjacency_ping - 
        self.router.configs.adjacency_update_milis
    ) .. '\n')
    term.setCursorPos(1,5)
    term.write('MAX_ADJ: ' .. self.router.configs.adjacency_unresponsive_removal_milis)
    term.setCursorPos(1,6)
    term.write('TICK: ' .. self.iteration)
    term.setCursorPos(1,8)
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

next_timer_id = 0

local function nextEvent(self,delay)
    local event, b, c, d, e, f = os.pullEvent()
    if event == 'timer' then
        onTick(self)
        --print('timer',next_timer_id)
        next_timer_id = os.startTimer(delay)
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
    self.modem.transmit(self.channel,self.channel,message)
    return true
end

--- @param self RouterWrapper
local function begin(self,delay)
    delay = delay or 0.5
    self.router.wrapper = self
    self.router:onStart()
    self.modem.open(self.channel)
    
    local monitor = peripheral.find("monitor")
    monitor.setTextScale(.5)
    if peripheral ~= nil then
        self.output_stream("Redirecting all output to connected monitor")
        term.redirect(monitor)
        monitor.setCursorPos(1,1)
        term.setCursorPos(1,1)
        term.clear()
    end
    self.output_stream("STARTING ROUTER " .. self.router.name .. " ON CHANNEL " .. self.channel)

    os.startTimer(delay)

    while self.should_be_running do
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