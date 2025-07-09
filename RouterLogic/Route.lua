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

local function getFirst(self)
    return self[1]
end

local function getLast(self)
    local i = 1
    while self[i] do
        i = i + 1
    end
    return self[i-1]
end

function Route(route_str)
    local route = {
        toString = toString,
        clone = clone,
        getUpdated = getUpdated,
        getFirst = getFirst,
        getLast = getLast
    }
    local c = 0
    for nd in string.gmatch(route_str,"%->%[(.-)]") do
        table.insert(route,nd)
        c = c + 1
    end
    route.size = c
    return route
end

return Route