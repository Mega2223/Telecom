---@class EndpointLogic.ProtocolParser
---@field parse fun(msg: string)

---@type table<integer, EndpointLogic.ProtocolParser>
ENDPOINT_PROTOCOL_STACK = ENDPOINT_PROTOCOL_STACK or {}

---@return EndpointLogic.ProtocolParser
function ProtocolParser()
    ---@type EndpointLogic.ProtocolParser
    return {
        parse = function (msg) end
    }
end