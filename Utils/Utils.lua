function getTypeName(obj)
    local t = type(obj)
    if t == 'table' then
        return t['type'] or t
    else
        return t
    end
end