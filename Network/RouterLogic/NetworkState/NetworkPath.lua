---@class NetworkPath
---@field from string
---@field to string
---@field path table<integer,string>
---@field reverse fun(self: NetworkPath): NetworkPath
---@field removeFirst fun(self: NetworkPath): NetworkPath
---@field removeLast fun(self: NetworkPath): NetworkPath
---@field toString fun(self: NetworkPath): string
---@field clone fun(self: NetworkPath): NetworkPath

---@param data string
---@return table<integer,string>
local function parse(data)
    local ret = {}
    local i = 1
    for router_name in string.gmatch(data, "([^=>]+)=>") do
        ret[i] = router_name
        i = i + 1
    end
    return ret
end

---@param self NetworkPath
---@return string
local function toString(self)
    local ret = ''
    for index, router_name in pairs(self.path) do
        ret = ret .. router_name .. '=>'
    end
    return ret
end

---@param self NetworkPath
---@return NetworkPath
local function reverse(self)
    print('REVERTENDO' .. self:toString())
    local ret = self:clone()
    for i = 1, #self.path do
        local mirror_index = #self.path - i + 1
        if not ret.path[mirror_index] or not ret.path[i] then
            error 'nil error'
        end
        print(i .. ' -> ' .. mirror_index .. '[' .. i .. '/' .. #self.path .. ']')
        print(self.path[i] .. ' fica em ' .. mirror_index)
        ret.path[mirror_index] = self.path[i]
    end
    print('RESULT' .. self:toString())
    return ret
end

---@param self NetworkPath
---@return NetworkPath
local function removeFirst(self)
    local ret = self:clone()
    table.remove(ret.path,1)
    return ret
end

---@param self NetworkPath
---@return NetworkPath
local function removeLast(self)
    local ret = self:clone()
    ret.path[#ret.path] = nil
    return ret
end

---@param self NetworkPath
---@return NetworkPath
local function clone(self)
    return NetworkPath(self.path)
end

---@param data string | table<integer,string>
---@return NetworkPath
function NetworkPath(data)
    local path
    if type(data) ~= "table" then
        path = parse(data)
    else
        path = data
    end

    ---@type NetworkPath
    return {
        path = path,
        reverse = reverse,
        toString = toString,
        from = path[1],
        to = path[#path],
        removeFirst = removeFirst,
        removeLast = removeLast,
        clone = clone
    }
end