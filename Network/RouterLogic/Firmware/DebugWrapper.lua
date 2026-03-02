require('Network.RouterLogic.Router')
socket = require('socket')

---@param self RouterFirmware
local function onTick(self)
    local time = math.floor(socket.gettime()*1000)
    self.router:doTick(time) -- timekeeping maybe?
    self.iteration = self.iteration + 1
end

---@param self RouterFirmware
local function onMessageReceived(self, message)
    self.router:onReceive(message)
end

---@param self DebugWrapper
local function transmitMessage(self, message)
    self.output_stream(self.router.configs.name ..' TRANSMIT: ' .. message)
    self.message_output_fun(message)
    return true
end

--- @param self DebugWrapper
local function begin(self)
    self.router.firmware = self
    self.router:onStart()
    self.output_stream("STARTING ROUTER " .. self.router.name .. " AS DEBUG")
end

---@class (exact) DebugWrapper: RouterFirmware
---@field runTick fun(self: DebugWrapper)
---@field onMessageReceived fun(self: DebugWrapper, message: string)
---@field message_output_fun fun(string)
---@field output_stream fun(string)

---Creates a ModemWrapper object
---@param router_object Router
---@param message_output_fun ?fun(string) where messagens will be sent
---@return DebugWrapper
function DebugWrapper(router_object, message_output_fun)
    ---@type DebugWrapper
    local wrapper = {
        transmitMessage = transmitMessage,
        modem = modem,
        router = router_object,
        begin = begin,
        should_be_running = true,
        message_output_fun = message_output_fun or function(msg) print(msg) end,
        output_stream = print,
        iteration = 1,
        runTick = onTick,
        onMessageReceived = onMessageReceived,
        last_transmition = 0,
        firmware_type = "DebugWrapper"
    }
    
    router_object.firmware = wrapper

    return wrapper
end

return DebugWrapper