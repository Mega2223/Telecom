
---@class KnownTransportEndpoint
---@field name string
---@field router string

---@class KnownTransportRouter
---@field name string
---@field connections table<string,string>

---@class ReceivedMessage
---@field from string
---@field data string
---@field instant_received integer

---@class TransportEntity
---@field address string | nil
---@field connected_router string | nil
---@field last_updated_connection_milis integer
---@field isConnected fun(self: TransportEntity): boolean
---@field estabilishConnection fun(self: TransportEntity, router_name: string|nil): boolean
---@field endConnection fun(self: TransportEntity)
---@field doLogic fun(self: TransportEntity, time_milis: integer)
---@field getNetworkEndpoints fun(self: TransportEntity, pattern: string): table<string,KnownTransportEndpoint>
---@field getRouters fun(self: TransportEntity): table<string,KnownTransportRouter>
---@field sendMessage fun(self: TransportEntity, dest: string, data: string, confirm: boolean | nil): boolean
---@field sendMulticast fun(self: TransportEntity, dest_patter: string, data: string)
---@field ping fun(self: TransportEntity, dest:string, max_wait_milis:integer | nil): integer | nil
---@field getInbox fun(self: TransportEntity, empty_inbox: boolean): table<string,string>

---@param self TransportEntity
local function doLogic(self)

end

local function isConnected(self)
    ---ask router 
end

---@param self TransportEntity
---@param router_name ?string
local function estabilishConnection(self, router_name)
    if router_name == nil then
        local ask = EndpointContractDatagram(ENDPOINT_CONTRACT_TASKS.PING_NEARBY,'','')
    enddsadsad key authenticator
end

local function endConnection(self) end

local function getNetworkEndpoints(self) end

local function getRouters(self) end

local function sendMessage(self) end

local function sendMulticast(self) end

local function ping(self) end

local function getInbox(self) end


TransportEntity = function()
    return {
        last_updated_connection_milis = 0,
        address = nil,
        connected_router = nil,
        isConnected = isConnected,
        estabilishConnection = estabilishConnection,
        endConnection = endConnection,
        doLogic = doLogic,
        getNetworkEndpoints = getNetworkEndpoints,
        getRouters = getRouters,
        sendMessage = sendMessage,
        sendMulticast = sendMulticast,
        ping = ping,
        getInbox = getInbox,
        output_stream = function(data) print(data) end
    }
end