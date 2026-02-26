---@diagnostic disable: undefined-global, assign-type-mismatch, param-type-mismatch, need-check-nil

--- Firmware wrapper intended for the Classic Peripherals antennas
--- not sure why those peripherals are classic but they are pretty cool

---@class (exact) RadioRouter: RouterFirmware
---@field radio_tower_peripheral RadioPeripheral
---@field frequency integer
---@field iteration integer

---@class RadioPeripheral
---@field broadcast fun(msg: string)
---@field canBroadcast fun(): boolean
---@field getFrequency fun(): integer
---@field getHeight fun(): integer
---@field isValid fun(): boolean
---@field setFrequency fun(freq: integer)

require('Utils.CCTUtils')
require('Network.RouterLogic.Router')

---@param self RadioRouter
local function onTick(self)
    local time = math.floor(1000 * os.clock())
    --print("time = " .. time)
    self.router:doTick(time)
    self.iteration = self.iteration + 1

    local file = fs.open("router.txt", "w")
    file.write(self.router.configs:toString())
    file.close()
    
    -- A lógica do router acaba aqui, embaixo é só renderização de informação da rede :p

    -- if time - LAST_RENDER < 1000 * .5 then return end
    -- render 
end

---@param self RadioRouter
local function onMessageReceived(self, event, side, message, distance)
    if self.router:onReceive(message) then
        print('SUCCESSFULLY PROCESSED MESSAGE:')
        print(message)
    end
end

local function nextEvent(self,delay)
    local event, b, c, d = os.pullEvent()
    if event == 'timer' then
        onTick(self)
        os.startTimer(delay)
    elseif event == 'radio_message' then
        onMessageReceived(self,event,b,c,d)
    end
end

---@param self RadioRouter
---@param message string
---@param milis_from_now ?integer
---@return boolean
local function transmitMessage(self, message, milis_from_now)
    milis_from_now = milis_from_now or 0
    print("SEND: \"".. message .."\"")
    self.radio_tower_peripheral.broadcast(message)
    return true
end

--- @param self RadioRouter
--- @param delay ?integer
local function begin(self,delay)
    delay = delay or 0.5
    self.router.firmware = self
    self.router:onStart()
    self.radio_tower_peripheral.setFrequency(self.frequency)
    
    ---@type ccTweaked.peripherals.Monitor
    local monitor = peripheral.find("monitor")
    if monitor ~= nil then
        monitor.setTextScale(.5)
        self.output_stream("Redirecting all output to connected monitor")
        term.redirect(monitor)
        monitor.setCursorPos(1,1)
        term.setCursorPos(1,1)
        term.clear()
    end
    self.output_stream("STARTING ROUTER " .. self.router.name .. " ON CHANNEL " .. self.frequency)

    os.startTimer(delay)

    while true do
        nextEvent(self,delay)
    end

    -- self.output_stream("ENDED ROUTER " .. self.router.name)
end


---@param frequency integer
---@return RadioRouter
function RadioRouter(frequency)
    ---@type RadioPeripheral
    local radio_tower_p = peripheral.find("radio_tower")
    radio_tower_p.setFrequency(frequency)

    ---@type RadioRouter
    return {
        onTick = onTick,
        onMessageReceived = onMessageReceived,
        nextEvent = nextEvent,
        transmitMessage = transmitMessage,
        begin = begin,
        frequency = frequency,
        radio_tower_peripheral = radio_tower_p,
        router = Router(getFileOrMakeEmpty('router.txt')),
        iteration = 0,
        output_stream = print
    }
end