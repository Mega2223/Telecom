require('Utils.Utils')

---@class RouterConfig
---@field toString fun(self: RouterConfig): string
---@field type 'RouterConfig'
---@field name string
---@field adjacency_update_milis integer

---@param self RouterConfig
---@return string
local function toString(self)
    return getTableAsConfig(self)
end

---RouterConfig object constructor
---@param configs RouterConfig | string | nil
---@return RouterConfig
function RouterConfig(configs)
    ---@type any
    local configs = configs
    if type(configs) == "nil" then configs = {} 
    elseif type(configs) == "string" then configs = getConfigFromData(configs) end

    ---@type RouterConfig
    local r = {
        type = 'RouterConfig',
        toString = toString,
        name = 'RT-' .. tostring(math.random(9999)),
        adjacency_update_milis = 10000 * 30
    }

    for key, value in pairs(configs) do
        r[key] = value
    end

    return r
end