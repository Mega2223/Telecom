---@class Vec3
---@field x number
---@field y number
---@field z number
---@field getNormalized fun(self: Vec3): Vec3
---@field getMagnitude fun(self: Vec3): number
---@field getFlipped fun(self: Vec3): Vec3
---@field getSum fun(self: Vec3, vecb: Vec3): Vec3
---@field getMinus fun(self: Vec3, vecb: Vec3): Vec3
---@field getMultiplied fun(self: Vec3, value: number): Vec3
---@field getCopy fun(self: Vec3): Vec3

---@param self Vec3
---@return Vec3
local function getCopy(self)
    return Vec3(self.x,self.y,self.z)
end

---@param self Vec3
---@param value number
---@return Vec3
local function getMultiplied(self, value)
    return Vec3(self.x * value,self.y * value,self.z * value)
end

---@param self Vec3
---@param vecb Vec3
---@return Vec3
local function getSum(self, vecb)
    return Vec3(self.x + vecb.x,self.y + vecb.y,self.z + vecb.z)
end

---@param self Vec3
---@param vecb Vec3
---@return Vec3
local function getMinus(self, vecb)
    return Vec3(self.x - vecb.x, self.y - vecb.y, self.z - vecb.z)
end

---@param self Vec3
---@return Vec3
local function getFlipped(self)
    return Vec3(-self.x, -self.y, -self.z)
end

---@param self Vec3
---@return number
local function getMagnitude(self)
    return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

---@param self Vec3
---@return Vec3
local function getNormalized(self)
    return self:getCopy():getMultiplied(1 / self:getMagnitude())
end

local metat = {
    __add = getSum,
    __mul = getMultiplied,
    __sub = getMinus,
    __unm = getFlipped
}

---@param x number
---@param y number
---@param z number
---@return Vec3
function Vec3(x, y, z)
    ---@type Vec3
    local ret = {
        x = x, y = y, z = z,
        getSum = getSum,
        getMagnitude = getMagnitude,
        getMinus = getMinus,
        getCopy = getCopy,
        getMultiplied = getMultiplied,
        getFlipped = getFlipped,
        getNormalized = getNormalized
    }
    setmetatable(ret,metat)
    return ret
end