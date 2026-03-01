---@diagnostic disable: need-check-nil

---@class (exact) RadioRouter: RouterFirmware
---Firmware wrapper intended for the Classic Peripherals antennas
---not sure why those peripherals are classic but they are pretty cool
---@field radio_tower_peripheral RadioPeripheral
---@field frequency integer
---@field iteration integer
---@field monitor ?ccTweaked.peripherals.Monitor

---@class RadioPeripheral
---@field broadcast fun(msg: string)
---@field canBroadcast fun(): boolean
---@field getFrequency fun(): integer
---@field getHeight fun(): integer
---@field isValid fun(): boolean
---@field setFrequency fun(freq: integer)

require('Utils.CCTUtils')
require('Network.RouterLogic.Router')

LAST_RENDER = 0

---@param self RadioRouter
local function onTick(self)
    local time = math.floor(1000 * os.clock())
    self.router:doTick(time)
    self.iteration = self.iteration + 1

    local file = fs.open("router.txt", "w")
    file.write(self.router.configs:toString())
    file.close()
    
    -- A lógica do router acaba aqui, embaixo é só renderização de informação da rede :p

    if self.monitor then
        local last_term = term.current()
        term.redirect(self.monitor)
        term.setCursorPos(1, 1)
        term.clear()
        
        print(string.format("Name: %s\nCurrent time: %d\n",self.router.name,time))
        print("Neighbors:")
        for key, neigh in pairs(self.router.memory.adjacent_routers) do
            print(string.format("%s: last seen %d/%d", neigh.name, neigh.last_updated,
                neigh.last_updated + self.router.configs.adjacency_unresponsive_removal_milis))
        end
        print("\nKnown Routers:")
        for key, router in pairs(self.router.memory.network_state.network_routers) do
            local network_routers = ""
            for key, connection in pairs(router.connections) do
                network_routers = network_routers .. connection .. " "
            end
            print(string.format("%s connections -> %s ", router.name, network_routers))
        end
        print("\nEndpoints: ")
        for name, endpoint in pairs(self.router.memory.connected_endpoints) do
            print(
                string.format("%s: last seen %d/%d", endpoint.address, endpoint.last_updated,
                    self.router.configs.endpoint_unresponsive_milis + endpoint.last_updated
                )
            )
        end
        term.redirect(last_term)
        LAST_RENDER = time
    end
end

---@param self RadioRouter
local function onMessageReceived(self, event, side, message, distance)
    if self.router:onReceive(message) then
        STD_OUT('SUCCESSFULLY PROCESSED MESSAGE:')
        STD_OUT(message)
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
    STD_OUT("SENDING MSG: \"".. message .."\"")
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
    ---@diagnostic disable-next-line: assign-type-mismatch
    self.monitor = peripheral.find("monitor")
    if self.monitor then
        STD_OUT("Redirecting all output to connected monitor")
    end
    STD_OUT("STARTING ROUTER " .. self.router.name .. " ON FREQUENCY " .. self.frequency)

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
    ---@diagnostic disable-next-line: assign-type-mismatch, param-type-mismatch
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
        output_stream = print,
        firmware_type_name = "RadioRouter"
    }
end

table.insert(ROUTER_FIRMWARE_WRAPPERS,RadioRouter(-1))