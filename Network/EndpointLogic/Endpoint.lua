require('Network.EndpointLogic.Protocol')
require('Network.EndpointLogic.EndpointConfig')
require('Network.EndpointLogic.EndpointMemory')
require('Network.CommonLogic.Datagrams.EndpointNegotiationDatagram')

---@class EndpointLogic.Endpoint
---@field do_logic fun(self: EndpointLogic.Endpoint, time_milis: integer)
---@field send_message fun(self: EndpointLogic.Endpoint, full_message: string): boolean
---@field send_message_to fun(self: EndpointLogic.Endpoint, destination_address: string, message: string)
---@field get_endpoints_at_network fun(self: EndpointLogic.Endpoint, pattern: nil|string): table<integer,string>
---@field is_connected fun(self: EndpointLogic.Endpoint): boolean
---@field time integer
---@field config EndpointLogic.Config
---@field memory EndpointLogic.Memory
---@field firmware ?EndpointLogic.Firmware
---@field onReceive fun(self: EndpointLogic.Endpoint, msg:  string): boolean

---@class EndpointLogic.Firmware
---@field send_message fun(self: EndpointLogic.Firmware, message: string): boolean

ENDPOINT_PROTOCOL_STACK = ENDPOINT_PROTOCOL_STACK or {}

---@param self EndpointLogic.Endpoint
---@param time_milis integer
local function do_logic(self, time_milis)
    self.time = time_milis

    if not self.memory.address and not self.memory.transaction_id then
        self.memory.transaction_id = string.format("TID%03d",math.random(999))
    end

    if self.memory.transaction_id and not self.memory.favorite_to_connect then
        for rt_name, router in pairs(self.memory.nearby_routers) do
            self.memory.favorite_to_connect = rt_name
            goto found_router
        end
        -- No routers in memory, ask for nearby routers
        local task = NearbyRoutersTask()
        local datagram = EndpointNegotiationDatagram('nil', 'nil', 'E', task)
        self:send_message(datagram:toString())
    end
    ::found_router::

    if self.memory.transaction_id then
        if self.time - self.memory.last_ping > self.config.update_interval / 2 then
                local task = string.format("GIVE_NAME<(%s)-%s>",self.config.prefix,self.memory.transaction_id)
                -- GIVE_NAME<(prefix|name)-transaction_id>
                local datagram = EndpointNegotiationDatagram(
                    self.memory.address,
                    self.memory.favorite_to_connect,
                    'E', task
            )
            self:send_message(datagram:toString())
            self.memory.last_ping = self.time
        end
    end

    if self.memory.address and
        self.time - self.memory.last_ping > self.config.update_interval then
        local task = string.format("UPDATE<%s>", self.memory.address)
        local datagram = EndpointNegotiationDatagram(
            self.memory.address, self.memory.connected_router,
            'E', task
        )
        self:send_message(datagram:toString())
        self.memory.last_ping = self.time
    end
    
    for r_name, router in pairs(self.memory.nearby_routers) do
        if self.time - router.last_seen > self.config.router_forget_threashold then
            self.memory.nearby_routers[r_name] = nil
        end
    end

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
    if not self.memory.connected_router then
        error('endpoint currently is not connected to a router')
    end
    ---MSG<(destination_address)-confirm:T|F-multicast:T|F-(message_content)> 
    local datagram_task = string.format("MSG<(%s)-%s-%s-(%s)>",
        destination_address,'F','F',message
    )

    local datagram = EndpointNegotiationDatagram(
    -- TODO peloamor deve ter um jeito mais padronizado de fazer isso
    -- acho que cada task deveria ter uma classe que extendesse alguma classe comum
        self.memory.address, self.memory.connected_router, 'E',datagram_task
    )
    self:send_message(datagram:toString())
end

---@param self EndpointLogic.Endpoint
---@return boolean
local function is_connected(self)
    return type(self.memory.connected_router) == "string"
end

local function get_endpoints_at_network(self)
    -- TODO
end

---@param self EndpointLogic.Endpoint
---@param msg string
---@return boolean
local function onReceive(self, msg)
    for index, protocol in pairs(ENDPOINT_PROTOCOL_STACK) do
        if protocol.onReceive(self,msg) then
            return true
        end
    end
    return false
end

---@param configs string | table<string,integer|string> | nil
---@param firmware ?EndpointLogic.Firmware
---@return EndpointLogic.Endpoint
function Endpoint(configs, firmware)
    ---@type EndpointLogic.Endpoint
    return {
        do_logic = do_logic,
        send_message = send_message,
        is_connected = is_connected,
        time = 0,
        config = EndpointConfig(configs),
        memory = EndpointMemory(),
        firmware = firmware,
        send_message_to = send_message_to,
        get_endpoints_at_network = get_endpoints_at_network,
        onReceive = onReceive
    }
end