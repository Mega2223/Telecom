require('Utils.CCTUtils')

--- TODO reunir funções similares entre o endpoint e o router

---@class (exact) EndpointLogic.RadioEndpoint: EndpointLogic.Firmware
---@field firmware_type 'RadioEndpoint'
---@field radio_peripheral RadioPeripheral
---@field frequency integer
---@field monitor ?ccTweaked.peripherals.Monitor

---@param self EndpointLogic.RadioEndpoint
local function doTick(self)
    local time = math.floor(1000 * os.clock())
    self.endpoint:do_logic(time)

    -- self.iteration = self.iteration + 1
    local file = fs.open("endpoint.txt", "w")
    if not file then error("could not write configs") end
    file.write(self.endpoint.config:toString())
    file.close()

    if self.monitor then
        local prev_term = term.current()
        self.monitor.setTextScale(.5)
        term.redirect(self.monitor)
        term.clear()
        term.setCursorPos(1, 1)
        print(string.format("TIME: %d PREFIX: \"%s\"",self.endpoint.time,self.endpoint.config.prefix))
        print(string.format("ADDRESS: %s TRANS_ID: %s\nCONN_ROUTER: %s FAV_ROUTER: %s",
        self.endpoint.memory.address, self.endpoint.memory.transaction_id,
        self.endpoint.memory.connected_router, self.endpoint.memory.favorite_to_connect
        ))
        print('')
        print("NEARBY_ROUTERS: ")
        for name, router in pairs(self.endpoint.memory.nearby_routers) do
            print(
                string.format("%s: %d/%d", name, router.last_seen,
                    router.last_seen + self.endpoint.config.router_forget_threashold
                ))
        end
        print('')
        term.redirect(prev_term)
    end
end

---@param self EndpointLogic.RadioEndpoint
---@param msg string
---@param event string
---@param side string
---@param distance number
---@return boolean
local function onMessageReceived(self, event, side, msg, distance)
    return self.endpoint:onReceive(msg)
end

---@param self EndpointLogic.RadioEndpoint
---@param delay number
local function nextEvent(self,delay)
    local event, b, c, d = os.pullEvent()
    if event == 'timer' then
        doTick(self)
        os.startTimer(delay)
    elseif event == 'radio_message' then
        onMessageReceived(self,event,b,c,d)
    end
end

---@param self EndpointLogic.RadioEndpoint
local function begin(self)
    delay = delay or 0.5
    self.endpoint.firmware = self
    --- self.endpoint:onStart()
    self.radio_peripheral.setFrequency(self.frequency)
    
    ---@type ccTweaked.peripherals.Monitor
    ---@diagnostic disable-next-line: assign-type-mismatch, inject-field
    self.monitor = peripheral.find("monitor")
    if self.monitor then
        STD_OUT("Redirecting all output to connected monitor")
    end
    STD_OUT("STARTING ENDPOINT " .. self.endpoint.config.prefix .. " FOR FREQUENCY " .. self.frequency)

    os.startTimer(delay)
    ---@diagnostic disable-next-line: assign-type-mismatch
    self.monitor = peripheral.find("monitor")

    while true do
        nextEvent(self,delay)
    end
end

---@param self EndpointLogic.RadioEndpoint
---@param message string
---@return boolean
local function sendMessage(self, message)
    STD_OUT("SENDING MSG: \"".. message .."\"")
    self.radio_peripheral.broadcast(message)
    return true
end

---@param frequency integer
---@return EndpointLogic.RadioEndpoint
function RadioEndpoint(frequency)
     ---@type RadioPeripheral
    ---@diagnostic disable-next-line: assign-type-mismatch, param-type-mismatch
    local radio_tower_p = peripheral.find("radio_tower")
    radio_tower_p.setFrequency(frequency)

    ---@type EndpointLogic.RadioEndpoint
    local ret = {
        ---@param self EndpointLogic.RadioEndpoint
        transmitMessage = function (self, msg)
            self.radio_peripheral.broadcast(msg) return true
        end,
        ---@diagnostic disable-next-line: param-type-mismatch, assign-type-mismatch
        radio_peripheral = radio_tower_p,
        doTick = doTick,
        onMessageReceived = onMessageReceived,
        firmware_type = 'RadioEndpoint',
        begin = begin,
        endpoint = Endpoint(getFileOrMakeEmpty('endpoint.txt')),
        send_message = sendMessage,
        frequency = frequency
    }
    ret.endpoint.firmware = ret
    return ret
end