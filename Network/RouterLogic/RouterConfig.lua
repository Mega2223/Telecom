require('Utils.Utils')

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
    return getTableAsConfig(self)
end

---RouterConfig object constructor
---@param configs RouterConfig | table | string | nil
---@return RouterConfig
function RouterConfig(configs)
    ---@type table | string | nil
    local configs = configs
    if type(configs) == "nil" then configs = {} 
    elseif type(configs) == "string" then configs = getConfigFromData(configs) end

    ---@type RouterConfig
    local r = {
        type = 'RouterConfig',
        toString = toString,
        name = string.format('RT-%05d', math.random(99999)),
        adjacency_update_milis = 1000 * 10,
        adjacency_unresponsive_removal_milis = 1000 * 30,
        adjacency_broadcast_milis = 1000 * 30,
        known_router_unresponsive_removal_milis = 1000 * 60,
        endpoint_unresponsive_milis = 1000 * 15
    }

    for key, value in pairs(configs) do
        r[key] = value
    end

    return r
end