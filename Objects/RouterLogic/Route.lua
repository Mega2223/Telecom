local function clone(self)
    return Route(self:toString())
end

local function toString(self)
    local st = ""
    local i = 1
    while self[i] do
        st = st .. "->[" .. self[i] .. "]"
        i = i + 1
    end
    return st
end

local function getUpdated(self)
    local i = 1
    local clone = self:clone()
    while self[i] do
        clone[i] = self[i+1]
        i = i + 1
    end
    return clone
end

function Route(route_str)
    local nodes = {
        toString = toString,
        clone = clone,
        getUpdated = getUpdated
    }
    for nd in string.gmatch(route_str,"%->%[(.-)]") do
        table.insert(nodes,nd)
    end
    return nodes
end