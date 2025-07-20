require('Network.Router')

---@param self RouterWrapper
local function onTick(self)
    self.router:doTick(os.time()*1000) -- timekeeping maybe?
    self.iteration = self.iteration + 1
end

---@param self RouterWrapper
local function onMessageReceived(self, message)
    self.router:onReceive(message)
end

---@param self DebugWrapper
local function transmitMessage(self, message)
    self.output_stream(self.router.configs.name ..' TRANSMIT: ' .. message)
    self.message_output_fun(message)
end

--- @param self RouterWrapper
local function begin(self)
    self.router.wrapper = self
    self.router:onStart()
    self.output_stream("STARTING ROUTER " .. self.router.name .. " AS DEBUG")
end

---@class DebugWrapper: RouterWrapper
---@field runTick fun(self: DebugWrapper)
---@field receiveMessage fun(self: DebugWrapper, message: string)
---@field message_output_fun fun(string)

---Creates a RouterWrapper object
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
        receiveMessage = onMessageReceived
    }
    
    router_object.wrapper = wrapper

    return wrapper
end

return RouterWrapper