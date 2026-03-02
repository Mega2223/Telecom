---@class NegotiationSubprotocol Negotiation tasks that are implemented by the END datagram
---@field onRouterReceive fun(router: Router, task_data: string, END: EndpointNegotiationDatagram): boolean
---@field onEndpointReceive fun(endpoint: EndpointLogic.Endpoint, task_data: string, END: EndpointNegotiationDatagram): boolean

---@type table<integer,NegotiationSubprotocol>
END_NEGOTIATION_TASKS = END_NEGOTIATION_TASKS or {}