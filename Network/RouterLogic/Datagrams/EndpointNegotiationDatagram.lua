-- The EndpointNegotiationDatagram class is a datagram intended to represent all possible interactions between an router and a datagram

---@class EndpointNegotiationDatagram this datagram does nothing

---@type table<integer, DatagramParser>
NETWORK_DATAGRAM_PROT = NETWORK_DATAGRAM_PROT or {}

---[END-(endpoint_address)-(router_name)-who_is_sending:R|E-task]
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
---@return string|nil, string|nil, string|nil, string|nil
local function parseData(data)
    local endpoint, router, sender, task =
        string.match(data, "%[END%-%((.+)%)%-%((.+)%)%-(.+)%-(.+)%]")
    if not endpoint then return nil end
    return endpoint, router, sender, task
end
---[END-(ENDPOINTNAME)-(ROUTERNAME)-E-TASKTASK]

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

-- TODO é bom ter o objeto para poder mudar o parseamento mais facil

---@class EndpointNegotiationDatagram
---@field endpoint_address string
---@field router_address string
---@field who_sent_it 'R'|'E'
---@field task string
---@field toString fun(self: EndpointNegotiationDatagram): string

---comment
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


---@param task_data string
---@return string | nil, string | nil
local function parseGiveNameTask(task_data)
    local prefix, id = string.match(task_data, "GIVE_NAME<(.+)%-(%d+)>")
    return prefix, id
end

---@param msg string
---@param router Router
---@return boolean
local function onMessageReceived(msg, router)
    local endpoint_address, router_name, sent_from_router, task = parseData(msg)
    --print('dat',endpoint_address,router_name,sent_from_router,task)
    if not endpoint_address then return false end
    if sent_from_router or router_name ~= router.name then return true end

    if task == "UPDATE" then
        router.memory:updateEndpoint(endpoint_address,router.current_time_milis)
    end

    local network_state = router.memory.network_state

    local prefix, id = parseGiveNameTask(task)
    if prefix and id then
        -- endpoint is asking for a name
        local i = math.random(9000)
        while i <= 15000 do
            local end_name = string.format("%s_%5d", prefix, i)
            i = i + 1
            if not network_state:getEndpointWithName(end_name) then
                ---[END-endpoint_address-(router_name)-who_is_sending:R|E-task]
                ---  GIVE_NAME<(prefix|name)-(transaction_id)>
                --name approved, send reply
                local reply = EndpointNegotiationDatagram(
                    end_name,router.name,'R',"GIVE_NAME<(%s)-(%s)>"
                )
                router:transmit(reply:toString())
                --TODO: also vc deveria forçar um broadcast na rede
                -- para o estado desse roteador ser atualizado nos demais
                return true
            end
        end
        STD_ERR("could not create name for endpoint " .. id)
        error("could not create name for endpoint " .. id)
    end

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