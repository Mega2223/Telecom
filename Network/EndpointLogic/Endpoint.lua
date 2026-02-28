require('Network.EndpointLogic.Protocol')
require('Network.EndpointLogic.EndpointConfig')

---@class EndpointLogic.Endpoint
---@field address ?string
---@field router ?string
---@field do_logic fun(self: EndpointLogic.Endpoint, time_milis: integer)
---@field send_message fun(self: EndpointLogic.Endpoint, full_message: string): boolean
---@field send_message_to fun(self: EndpointLogic.Endpoint, destination_address: string, message: string)
---@field get_endpoints_at_network fun(self: EndpointLogic.Endpoint, pattern: nil|string): table<integer,string>
---@field is_connected fun(self: EndpointLogic.Endpoint): boolean
---@field time integer
---@field config EndpointLogic.Config
---@field firmware ?EndpointLogic.Firmware
---@field protected teste ?string

---@class EndpointLogic.Firmware
---@field send_message fun(self: EndpointLogic.Firmware, message: string): boolean

---@param self EndpointLogic.Endpoint
---@param time_milis integer
local function do_logic(self, time_milis)
    self.time = time_milis
end

---Sends
---@param self EndpointLogic.Endpoint
---@param message string
local function send_message(self, message)
    if not self.firmware then
        error('error sending message: no firmware :\\')
    end
    self.firmware:send_message(message)
end

---@param self EndpointLogic.Endpoint
---@param destination_address string
---@param message string
local function send_message_to(self, destination_address, message)
    if self:get_endpoints_at_network()[destination_address] == nil then
        error('endpoint ' .. destination_address .. ' does not exist')
    end
    
end

local function is_connected()
    
end

---@param configs string | table<string,integer|string> | nil
---@return EndpointLogic.Endpoint
function Endpoint(configs)
    ---@type EndpointLogic.Endpoint
    return {
        do_logic = do_logic,
        send_message = send_message,
        is_connected = is_connected,
        time = 0,
        config = EndpointConfig(configs)
    }
end