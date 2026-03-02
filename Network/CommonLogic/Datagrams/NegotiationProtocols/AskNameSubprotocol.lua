require('Network.CommonLogic.Datagrams.NegotiationProtocols.BaseNegotiationProtocol')

---@param task_data string
---@return string | nil, string | nil
local function parse(task_data)
    local prefix_or_address, id = string.match(task_data, "GIVE_NAME<%((.*)%)%-(.+)>")
    -- print(task_data,'-> PARSE ->',prefix_or_address, id)
    return prefix_or_address, id
end

---@param transaction_id string
---@param prefix_or_address ?string
function AskNameSubprotocol(transaction_id, prefix_or_address)
    local prefix_or_address = prefix_or_address or ""
    return string.format("GIVE_NAME<(%s)-%s>",prefix_or_address,transaction_id)
end

---@param endpoint EndpointLogic.Endpoint 
---@param task_data string
---@param END EndpointNegotiationDatagram
---@return boolean
local function onEndpointReceive(endpoint, task_data, END)
    local address, t_id = parse(task_data)
    if not address or not t_id then
        -- print(task_data,'somehow failed to parse',address,t_id)
        return false
    end
    STD_OUT(("Got address (%s) from router (%s)").format(address,END.router_address))
    endpoint.memory.transaction_id = nil
    endpoint.memory.address = address
    endpoint.memory.last_ping = -1
    endpoint.memory.connected_router = END.router_address
    endpoint.memory.favorite_to_connect = nil
    return true
end

---@param router Router
---@param task_data string
---@param END EndpointNegotiationDatagram
local function onRouterReceive(router, task_data, END)
    local prefix, t_id = parse(task_data)
    if not prefix or not t_id then return false end
    if prefix and t_id then
        STD_OUT "GIVENAME"
        -- endpoint is asking for a name
        local i = math.random(9000)
        while i <= 15000 do
            local end_name = string.format("%s_%05d", prefix, i)
            i = i + 1
            if not router.memory.network_state:getEndpointWithName(end_name) then
                --name approved, send reply
                local reply = EndpointNegotiationDatagram(
                    end_name, router.name, 'R',
                    AskNameSubprotocol(t_id,end_name)
                )
                router:transmit(reply:toString())
                router.memory:registerEndpoint(end_name,router.current_time_milis)
                --TODO: also vc deveria forçar um broadcast na rede
                -- para o estado desse roteador ser atualizado nos demais
                return true
            end
        end
        STD_ERR("could not create name for endpoint " .. t_id)
        error("could not create name for endpoint " .. t_id)
    end
end

---@type NegotiationSubprotocol
local protocol = {
    onEndpointReceive = onEndpointReceive,
    onRouterReceive = onRouterReceive,
    name = "AskNameSubprotocol"
}

table.insert(END_NEGOTIATION_TASKS,protocol)