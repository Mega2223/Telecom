-- The EndpointNegotiationDatagram class is a datagram intended to represent all possible interactions between an router and a datagram

---@class EndpointNegotiationDatagram this datagram does nothing

---@type table<integer, DatagramParser>
NETWORK_DATAGRAM_PROT = NETWORK_DATAGRAM_PROT or {}

---[END-endpoint_address-router_name-who_is_sending:R|E-task]
---
---task:
---  UPDATE -> "endpoint is still alive"
---     endpoint should send this frequently out of its own initiative

---  MSG<(destination_address)-(confirm:T|F)-(multicast:T|F)-(message_content)> -> send message to address
---     endpoint sends this message to ask router to send message to this address
---     router sends this message when it receives a message to one of its endpoints
---     destination_address is a pattern if multicast

---  GET_HOST<(host_pattern|host_list)> -> "give me all hosts that match this pattern"
---     endpoints ask for a list of other endpoints in the network who match this pattern
---     router replies an array of all known names that match this pattern

---  GIVE_NAME<(prefix|name)-(transaction_id)>
---     endpoint asks for a name with this given prefix, router assigns an address to the endpoint
---     and replies the assigned name, endpoint_address is nil in this case as it is not assigned yet

---@param data string
local function parseData(data)
    local endpoint, router, sender, task =
        string.match(data, "%[END%-(.+)%-(.+)%-(.+)%-(.+)%]")
    if not endpoint then return nil end
    return endpoint, router, sender == 'R', task
end

local function onMessageReceived(msg, router)
    local endpoint_address, router_name, sent_from_router, task = parseData(msg)
    if not endpoint_address then return false end

    --TODO wlkelçak

    return true
end

local function onDie()
    -- Message never dies
end

local template_parser = {
    onDie = onDie,
    onMessageReceived = onMessageReceived,
    type = 'EndpointNegotiationDatagramParser'
}


table.insert(NETWORK_DATAGRAM_PROT,template_parser)