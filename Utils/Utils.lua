---@diagnostic disable: undefined-global
require('Utils.Debug')

WORK_PATH =  ""

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
---@return table|nil
function getConfigFromData(data)
    local ret = textutils.unserialise(data)
    return ret
end

---@param data table<integer,string>
---@return string
function listToString(data)
    local ret = ""
    for i = 1, #data do
        ret = ret .. "(" .. data[i] .. ")"
    end
    return ret
end

---@param data string
---@return table<integer,string> | nil
function stringToList(data)
    local i = 1
    local ret = {}
    if data == 'nil' then return ret end
    --STD_OUT"STRINGANDO PARA LISTANDO"
    for entry in string.gmatch(data, "%(([^(^)]+)%)") do
    --    STD_OUT('property' .. i .. ' -> ' .. entry)
        ret[i] = entry
        i = i + 1
    end
    if ret[1] == nil then
    --    STD_OUT "RETORNANDO NADA"
        return nil
    end
    return ret
end