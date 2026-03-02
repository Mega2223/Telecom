---@class EndpointLogic.Config
---@field update_interval integer interval in which the endpoint affirms it's existance to the router
---@field nearby_router_update_interval integer 
---@field router_forget_threashold integer
---@field update_network_endpoints integer
---@field network_endpoint_forget_threashold integer
---@field prefix string
---@field toString fun(self: EndpointLogic.Config): string

---@param self EndpointLogic.Config
---@return string
local function toString(self)
    local ret = ""
    for key, value in pairs(self) do
        if type(value) =="string" or type(value) =="number" then
            ret = ret .. string.format("%s<=%s\n",key,tostring(value))
        end
    end
    return ret
end

---@param data string
---@return table<string,string|number>
local function fromString(data)
    local ret = {}
    for key, value in string.gmatch(data,"([^\n]+)<=([^\n]+)\n") do
        ret[key] = tonumber(value) or value
    end
    return ret
end

---@param data table<string,string|number> | string | nil
---@return EndpointLogic.Config
function EndpointConfig(data)
    if type(data) == "nil" then
        data = {}
    elseif type(data) == "string" then
        data = fromString(data)
    end

    ---@type EndpointLogic.Config
    local ret = {
        update_interval = 6 * 1000,
        router_forget_threashold = 30 * 1000,
        nearby_router_update_interval = 13 * 1000,
        update_network_endpoints = 21 * 1000,
        network_endpoint_forget_threashold = 40 * 1000,
        prefix = "EDP",
        toString = toString
    }

    for key, value in pairs(data) do
        ret[key] = value
    end

    return ret
end