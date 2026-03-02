---@type table<integer, DatagramParser>
NETWORK_DATAGRAM_PROT = NETWORK_DATAGRAM_PROT or {}
---@type table<integer, EndpointLogic.ProtocolParser>
ENDPOINT_PROTOCOL_STACK = ENDPOINT_PROTOCOL_STACK or {}
---@type table<integer,NegotiationSubprotocol>
END_NEGOTIATION_TASKS = END_NEGOTIATION_TASKS or {}

require('Network.CommonLogic.Datagrams.NegotiationProtocols.AskNameSubprotocol')
require('Network.CommonLogic.Datagrams.NegotiationProtocols.BaseNegotiationProtocol')
require('Network.CommonLogic.Datagrams.NegotiationProtocols.NearbyRoutersSubprotocol')
require('Network.CommonLogic.Datagrams.NegotiationProtocols.UpdateSubprotocol')

---[END-(endpoint_address)-(router_name)-who_is_sending:R|E-task]
---
---task:
---  UPDATE<endpoint_address> -> "endpoint is still alive"
---     endpoint should send this frequently out of its own initiative
---
---  MSG<(destination_address)-confirm:T|F-multicast:T|F-(message_content)> -> send message to address
---     endpoint sends this message to ask router to send message to this address
---     router sends this message when it receives a message to one of its endpoints
---     destination_address is a pattern if multicast

---  GET_HOST<(host_pattern|host_list)> -> "give me all hosts that match this pattern"
---     endpoints ask for a list of other endpoints in the network who match this pattern
---     router replies an array of all known names that match this pattern
---
---  NEARBY_ROUTERS<who_sent:R|E-(ROUTER_NAME|nil)>
---     endpoints asks for routers withing proximity and routers answer with their names
---
---  GIVE_NAME<(prefix|name)-transaction_id>
---     endpoint asks for a name with this given prefix, router assigns an address to the endpoint
---     and replies the assigned name, endpoint_address is nil in this case as it is not assigned yet
---
--- DENY<endpoint_name>
---     router signals that the endpoint address is no longer valid and the endpoint
---     should ask for a new address, sent for invalid operations due to invalid adresses


---@param data string
---@return string|nil, string|nil, string|nil, string|nil
local function parseData(data)
    local endpoint, router, sender, task =
        string.match(data, "%[END%-%((.+)%)%-%((.+)%)%-([RE])%-(.+)%]")
    if not endpoint then return end
    return endpoint, router, sender, task
end

---@param self EndpointNegotiationDatagram
---@return string
local function toString(self)
    return string.format("[END-(%s)-(%s)-%s-%s]",
        self.endpoint_address,
        self.router_address,
        self.who_sent_it,
        self.task
    )
end

---@class EndpointNegotiationDatagram The EndpointNegotiationDatagram class is a datagram intended to represent all possible interactions between an router and a datagram
---@field endpoint_address string
---@field router_address string
---@field who_sent_it 'R'|'E'
---@field task string
---@field toString fun(self: EndpointNegotiationDatagram): string

---@param endpoint_address string
---@param router_address string
---@param who_sent_it 'R'|'E'
---@param task string
---@return EndpointNegotiationDatagram
function EndpointNegotiationDatagram(endpoint_address, router_address, who_sent_it, task)
    ---@type EndpointNegotiationDatagram
    return {
        endpoint_address = endpoint_address,
        router_address = router_address,
        who_sent_it = who_sent_it,
        task = task,
        toString = toString
    }
end

---@param msg string
---@param router Router
---@return boolean
local function onMessageReceivedRouter(msg, router)
    local endpoint_address, router_name, sender, task = parseData(msg)
    if not endpoint_address or not task or not router_name or not sender then return false end
    if sender == 'R' or (router_name ~= router.name and router_name ~= 'nil') then
        return true
    end

    local negotiation_d = EndpointNegotiationDatagram(endpoint_address, router_name, sender, task)
    
    for index, subprotocol in pairs(END_NEGOTIATION_TASKS) do
        -- print(string.format("trying protocol %s",subprotocol.name))
        if subprotocol.onRouterReceive(router, task, negotiation_d) then
            return true
        end
    end
    STD_OUT("msg= "..msg)
    STD_ERR "Is END datagram but no compatible task found"
    error "Is END datagram but no compatible task found"
    return false
end

---@param msg string
---@param endpoint EndpointLogic.Endpoint
---@return boolean
local function onMessageReceivedEndpoint(endpoint, msg)
    local endpoint_address, router_name, sender, task = parseData(msg)
    if not task or not sender or not router_name or not endpoint_address then return false end
    if sender == 'E' then return true end

    datagram = EndpointNegotiationDatagram(endpoint_address,router_name,sender,task)
    
    local negotiation_d = EndpointNegotiationDatagram(endpoint_address, router_name, sender, task)

    for index, subprotocol in pairs(END_NEGOTIATION_TASKS) do
        print(string.format("trying protocol %s",subprotocol.name))
        if subprotocol.onEndpointReceive(endpoint, task, negotiation_d) then
            return true
        end
    end
    STD_OUT("msg=" .. msg)
    error'IS END PROTOCOL BUT NO SUBPROTOCOL FOUND'
end

---@type DatagramParser
local parser_router = {
    onDie = function() end,
    onMessageReceived = onMessageReceivedRouter,
    type = 'EndpointNegotiationDatagramParser'
}

table.insert(NETWORK_DATAGRAM_PROT, parser_router)

---@type EndpointLogic.ProtocolParser
local parser_endpoint = {
    onReceive = onMessageReceivedEndpoint
}

table.insert(ENDPOINT_PROTOCOL_STACK,parser_endpoint)