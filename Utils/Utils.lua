---@diagnostic disable: undefined-global
require('Utils.Debug')

---gets the class name of the object if it's a table, otherwise returns the object type
---@param obj any
---@return string
function getTypeName(obj)
    local t = type(obj)
    if t == 'table' then
        return obj['type'] or t
    else
        return t
    end
end

---Serializes the table, ignores tables and 
---@param table_to table
---@return string
function getTableAsConfig(table_to)
    local r = {}
    for key, value in pairs(table_to) do
        if type(value) ~= "table" and type(value) ~= "function" and type(value) ~= "thread" then
            r[key] = value
        end
    end
    return textutils.serialise(r)
end

---@param data string
---@return table
function getConfigFromData(data)
    local ret = textutils.unserialise(data)
    return ret
end