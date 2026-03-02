---@class EndpointLogic.ProtocolParser
---@field onReceive fun(endpoint: EndpointLogic.Endpoint, msg: string): boolean

---@class EndpointLogic.Protocol
---@field toString fun(self: EndpointLogic.Protocol): string

---@type table<integer, EndpointLogic.ProtocolParser>
ENDPOINT_PROTOCOL_STACK = ENDPOINT_PROTOCOL_STACK or {}

---@type EndpointLogic.ProtocolParser
local protocol = {
    onReceive = function (endpoint, msg) return false end
}

table.insert(ENDPOINT_PROTOCOL_STACK, protocol)