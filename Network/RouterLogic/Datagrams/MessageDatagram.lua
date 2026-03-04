--[MSG-[%SENDER_ROUTER%]-[%NEXT_ROUTER%]-[%FINAL_ROUTER%]-%DESTINATION-%TIME_TO_DIE%-%CONFIRM%:T|F-(%PATH%)-(%MESSAGE%)]

---@class MessageDatagram Describes a message sent through the network
---@field sender_address string
---@field next_router string
---@field final_router string
---@field destination string
---@field time_to_die integer
---@field confirm boolean
---@field path NetworkPath
---@field message string
---@field toString fun(self: MessageDatagram): string

---@type table<integer, DatagramParser>
NETWORK_DATAGRAM_PROT = NETWORK_DATAGRAM_PROT or {}

---@param self MessageDatagram
---@return string
local function toString(self)
    local con = 'F'
    if self.confirm then con = 'T' end
    return string.format("[MSG-[%s]-[%s]-[%s]-[%s]-%d-%s-(%s)-(%s)]",
    self.sender_address, self.next_router, self.final_router, self.destination, self.time_to_die, con, self.path:toString(), self.message
)
end

---@param sender_address string
---@param final_router string
---@param next_router string
---@param destination string
---@param time_to_die string | integer
---@param confirm 'T' | 'F' | boolean
---@param path string
---@param message string
---@return MessageDatagram
function MessageDatagram(sender_address, next_router, final_router, destination, time_to_die, confirm, path, message)
    ---@type MessageDatagram
    return {
        sender_address = sender_address, final_router = final_router, next_router = next_router,
        destination = destination, time_to_die = tonumber(time_to_die) or 0,
        confirm = confirm == 'T' or confirm == true, path = NetworkPath(path), message = message,
        toString = toString
    }
end

---@param data string
---@return string|nil, string, string, string, string, string, string, string
local function parse(data)
    local sender, next_router, final_router, destination, time_to_die, confirm, path, message =
        string.match(data, "%[MSG%-%[(.+)%]%-%[(.+)%]%-%[(.+)%]%-%[(.+)%]%-(%d+)%-([TF])-%((.+)%)%-%((.+)%)%]")
    --[MSG-%SENDER%-%NEXT_ROUTER%-%FINAL_ROUTER%-%DESTINATION-%TIME_TO_DIE%-%CONFIRM%:T|F-(%PATH%)-(%MESSAGE%)]
    return sender, next_router, final_router, destination, time_to_die, confirm, path, message
end

-- [MSG-[EDP_03722]-[RT-VILA2]-[RT-VILA5]-[EDP_01285]-30-F-(RT-VILA2=>RT-VILA3=>RT-VILA4=>RT-VILA5=>)-(TESTE123)]

---@param msg string
---@param router Router
---@return boolean
local function onMessageReceived(msg, router)
    local data = { parse(msg) }
    --STD_OUT ('parsin\'' .. msg .. '\n=>\n' .. msg)
    if not data[1] then return false end
    local msg_dat = MessageDatagram(data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8])

    if msg_dat.next_router == router.name and msg_dat.final_router == router.name then
        -- is final router
        local confirm = 'F'
        if msg_dat.confirm then confirm = 'T' end
        local task = MessageSubprotocol(
            msg_dat.destination, msg_dat.sender_address, confirm, 'F', msg_dat.message)
        local to_send = EndpointNegotiationDatagram(msg_dat.destination,router.name,'R',task)
        router:transmit(to_send:toString())

    elseif msg_dat.next_router == router.name then
        -- pass to next router
        local new_path = msg_dat.path:removeFirst()
        local new_next = new_path.path[1]
        local to_send = MessageDatagram(
            msg_dat.sender_address, new_next, msg_dat.final_router, msg_dat.destination, msg_dat.time_to_die - 1,
            msg_dat.confirm, new_path:toString(), msg_dat.message
        )

        router:transmit(to_send:toString())
    end
    return true
end

local function onDie()
    
end

local template_parser = {
    onDie = onDie,
    onMessageReceived = onMessageReceived,
    type = 'TemplateDatagramParser'
}


table.insert(NETWORK_DATAGRAM_PROT,template_parser)