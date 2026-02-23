---@class RouterConfig
---@field toString fun(self: RouterConfig): string
---@field type 'RouterConfig'
---@field name string
---@field adjacency_update_milis integer
---@field adjacency_unresponsive_removal_milis integer
---@field adjacency_broadcast_milis integer
---@field known_router_unresponsive_removal_milis integer
---@field endpoint_unresponsive_milis integer

---@param self RouterConfig
---@return string
local function toString(self)
    local data = ""
    for key, value in pairs(self) do
        if type(value) == "number" or type(value) =="string" or type(value) == "boolean" then
            data = data .. key .. "=" .. value .. "\n"
        end
    end
    return data
end

---@param data string
---@return RouterConfig
local function fromString(data)
    local configs = {}
    for key, value in string.gmatch(data, "([%w_ ]+)=([%w_%- ]+)\n") do
        if tonumber(value) then
            value = tonumber(value)
        end
        configs[key] = value
        --print(string.format("MATCH \"%s\"=\"%s\"",key,value))
    end
    return RouterConfig(configs)
end

---@param cfg RouterConfig
local function printConfig(cfg)
    for key, value in pairs(cfg) do
        if type(key) ~= "function" then
            print(string.format("\"%s\":\"%s\"",tostring(key),tostring(value)))
        end
    end
end

---RouterConfig object constructor
---@param configs RouterConfig | table | string | nil
---@return RouterConfig
function RouterConfig(configs)
    ---@type table | string | nil
    local configs = configs
    if type(configs) == "nil" then configs = {} 
    elseif type(configs) == "string" then configs = fromString(configs) end

    ---@type RouterConfig
    local r = {
        type = 'RouterConfig',
        toString = toString,
        name = string.format('RT-%05d', math.random(99999)),
        adjacency_update_milis = 1000 * 10,
        adjacency_unresponsive_removal_milis = 1000 * 30,
        adjacency_broadcast_milis = 1000 * 30,
        known_router_unresponsive_removal_milis = 1000 * 60,
        endpoint_unresponsive_milis = 1000 * 15,
        print = printConfig
    }

    for key, value in pairs(configs) do
        r[key] = value
    end

    return r
end