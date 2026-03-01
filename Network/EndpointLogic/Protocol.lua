---@class EndpointLogic.ProtocolParser
---@field onReceive fun(endpoint: EndpointLogic.Endpoint, msg: string): boolean

---@class EndpointLogic.Protocol
---@field toString fun(self: EndpointLogic.Protocol): string

---@type table<integer, EndpointLogic.ProtocolParser>
ENDPOINT_PROTOCOL_STACK = ENDPOINT_PROTOCOL_STACK or {}

---@return EndpointLogic.ProtocolParser
function ProtocolParser()
    ---@type EndpointLogic.ProtocolParser
    return {
        onReceive = function (endpoint, msg)
            return false
        end
    }
end

table.insert(ENDPOINT_PROTOCOL_STACK, ProtocolParser())