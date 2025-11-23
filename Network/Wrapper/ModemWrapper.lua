--- A classe ModemWrapper é um wrapper da classe Router para fazer um
--- enlace usando o peripheral Modem do CCTweaked
--- A fim de poder tanto conseguir receber mensagens via eventos de modem como
--- poder executar a lógica periódica, ele usa a lógica interna de eventos do CCT,
--- onde a cada tick ele dispara um alarme para um tick seguinte e aguarda o próximo evento,
--- esse pode ser o alarme da iteração seguinte ou um recebimento de mensagem pelo modem, que
--- é assíncrono em relação ao relógio interno do Router

---@diagnostic disable: undefined-global, undefined-field

require('Network.Router')

---@class ModemWrapper
---@field transmitMessage fun(self: ModemWrapper, message: string): boolean
---@field router Router
---@field begin fun(self: ModemWrapper)
---@field iteration integer
---@field last_transmition integer

LAST_RENDER = 0

---@param self ModemWrapper
local function onTick(self)
    local time = math.floor(1000*os.clock())
    self.router:doTick(time)
    self.iteration = self.iteration + 1
    -- A lógica do router acaba aqui, embaixo é só renderização de informação da rede :p

    if time - LAST_RENDER < 1000 * .5 then return end
    local pretty = require('cc.pretty')
    LAST_RENDER = time
    term.clear()

    local s = self.router.memory.network_state:toString()
    local x,y = term.getSize()
    term.setCursorPos(1,y/2)
    --pretty.pretty_print(self.router.memory.network_state.routers[1])
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
    
    term.write('ADJACENCIES:\n')
    pretty.pretty_print(self.router.memory.adjacent_routers)
end

---@param self ModemWrapper
local function onMessageReceived(self,  event, side, channel, replyChannel, message, distance)
    if self.router:onReceive(message) then
        print('PROCESSED')
        print(message)
        --self.router:transmit('AAAAAAAAHH')
    end
end

NEXT_TIMER_ID = 0

local function nextEvent(self,delay)
    local event, b, c, d, e, f = os.pullEvent()
    if event == 'timer' then
        onTick(self)
        --print('timer',next_timer_id)
        NEXT_TIMER_ID = os.startTimer(delay)
    elseif event == 'modem_message' then
        onMessageReceived(self,event,b,c,d,e,f)
    end
end

---@param self ModemWrapper
---@param message string
---@param milis_from_now ?integer
---@return boolean
local function transmitMessage(self, message, milis_from_now)
    milis_from_now = milis_from_now or 0
    self.modem.transmit(self.channel,self.channel,message)
    return true
end

--- @param self ModemWrapper
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

---Creates a ModemWrapper object
---@param router_object Router
---@param channel integer | nil
---@param output_stream fun(string) | nil
---@return ModemWrapper
function ModemWrapper(router_object, channel, output_stream)
    local modem = peripheral.find("modem")
    ---@type ModemWrapper
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

return ModemWrapper