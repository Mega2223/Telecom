---@class EndpointLogic.EndpointNegotiationDatagram: EndpointLogic.Protocol
---@field router string
---@field endpoint string
---@field sender 'E'|'R'
---@field task string

---@class EndpointLogic.EndpointNegotiationDatagramParser: EndpointLogic.ProtocolParser

--- copied from the router END protocol
---@param data string
---@return string|nil, string|nil, string|nil, string|nil
local function parse_data(data)
    local endpoint, router, sender, task =
        string.match(data, "%[END%-%((.+)%)%-%((.+)%)%-([RE])%-(.+)%]")
    if not endpoint then return nil end
    return endpoint, router, sender, task
end

---comment
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
        toString = function (self)
            
        end
    }
end

---@return EndpointLogic.EndpointNegotiationDatagramParser
function EndpointNegotiationDatagramParser()
    ---@type EndpointLogic.EndpointNegotiationDatagram
    return {
        
    }
end

table.insert(ENDPOINT_PROTOCOL_STACK,EndpointNegotiationDatagramParser())