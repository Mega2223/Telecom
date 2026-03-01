--- TODO eu acho que da pra fazer um commons baseado nesse END e o END do roteador
--- pra parsear principalmente é importante que isso esteja consistente

---@class EndpointLogic.EndpointNegotiationDatagram: EndpointLogic.Protocol
---@field router string
---@field endpoint string
---@field sender 'E'|'R'
---@field task string

---@class EndpointLogic.EndpointNegotiationDatagramParser: EndpointLogic.ProtocolParser

---@class EndpointNegotiationDatagramTask
---@field task_name string
-- sera que vale a pena fazer subclasses? a questao da task e realmente mto complicada

--- copied from the router END protocol
---@param data string
---@param endpoint EndpointLogic.Endpoint
---@return boolean
local function onReceive(endpoint, data)
    local endpoint_name, router, sender, task =
        string.match(data, "%[END%-%((.+)%)%-%((.+)%)%-([RE])%-(.+)%]")
    if not task then return false end
    if sender == 'E' then return true end

    datagram = EndpointNegotiationDatagram(endpoint_name,router,sender,task)

    do
        local new_name, trans_id = string.match(task, "GIVE_NAME<%((.+)%)%-%((.+)%)>")
        if endpoint.memory.transaction_id == trans_id then
            endpoint.memory.address = new_name
            endpoint.memory.transaction_id = nil
            endpoint.memory.connected_router = router
            endpoint.memory.last_ping = -1
            return true
        end
    end

    return true
end

---@param endpoint string
---@param router string
---@param sender string
---@param task string
---@return EndpointLogic.EndpointNegotiationDatagram
function EndpointNegotiationDatagram(endpoint, router, sender, task )
    ---@type EndpointLogic.EndpointNegotiationDatagram
    return {
        endpoint = endpoint,
        router = router,
        sender = sender,
        task = task,
        ---@param self EndpointLogic.EndpointNegotiationDatagram
        toString = function (self)
            return string.format("[END-(%s)-(%s)-%s-%s]",
                self.endpoint,
                self.router,
                self.sender,
                self.task
        )
        end
    }
end

---@return EndpointLogic.EndpointNegotiationDatagramParser
function EndpointNegotiationDatagramParser()
    ---@type EndpointLogic.EndpointNegotiationDatagramParser
    return {
        onReceive = onReceive
    }
end

table.insert(ENDPOINT_PROTOCOL_STACK,EndpointNegotiationDatagramParser())