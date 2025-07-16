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