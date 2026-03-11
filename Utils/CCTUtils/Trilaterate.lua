--- This is a modified version of the CC:T trilteration algorithm
--- and as such is not subject to the GNU license of this repository, but
--- instead to CC:T's own license, available at:
--- https://github.com/cc-tweaked/CC-Tweaked/blob/mc-1.20.x/LICENSES/LicenseRef-CCPL.txt

CHANNEL_GPS = 65534

---@param A RouterPosition
---@param B RouterPosition
---@param C RouterPosition
---@return Vec3 | nil, Vec3 | nil
local function trilaterate(A, B, C)
    local A, B, C = {
        vPosition = Vec3(A.x,A.y,A.z), nDistance = A.dist
    }, {
        vPosition = Vec3(B.x,B.y,B.z), nDistance = B.dist
    }, {
        vPosition = Vec3(C.x,C.y,C.z), nDistance = C.dist
    }
    ---@type Vec3
    local a2b = B.vPosition - A.vPosition
    ---@type Vec3
    local a2c = C.vPosition - A.vPosition

    if math.abs(a2b:getNormalized():getDotProduct(a2c:getNormalized())) > 0.999 then
        -- TODO acho q aqui deu merda
        return nil
    end

    local d = a2b:getMagnitude()
    ---@type Vec3
    local ex = a2b:getNormalized()
    local i = ex:getDotProduct(a2c)
    ---@type Vec3
    local ey = (a2c - (ex * i)):getNormalized()
    local j = ey:getDotProduct(a2c)
    ---@type Vec3
    local ez = ex:getCrossProduct(ey)

    local r1 = A.nDistance
    local r2 = B.nDistance
    local r3 = C.nDistance

    local x = (r1 * r1 - r2 * r2 + d * d) / (2 * d)
    local y = (r1 * r1 - r3 * r3 - x * x + (x - i) * (x - i) + j * j) / (2 * j)

    ---@type Vec3
    local result = A.vPosition + (ex * x) + (ey * y)

    local zSquared = r1 * r1 - x * x - y * y
    if zSquared > 0 then
        local z = math.sqrt(zSquared)
        ---@type Vec3
        local result1 = result + (ez * z)
        ---@type Vec3
        local result2 = result - (ez * z)
        ---@type Vec3, Vec3
        local rounded1, rounded2 = result1:getRounded(0.01), result2(0.01)
        if rounded1.x ~= rounded2.x or rounded1.y ~= rounded2.y or rounded1.z ~= rounded2.z then
            return rounded1, rounded2
        else
            return rounded1
        end
    end
    return result:getRounded(0.01)
end

---@param positions table<integer,RouterPosition>
---@return Vec3 | nil
function getLocation(positions)
    if not positions then
        error 'not positions'
    end
    for i = 1, #positions do
        for j = i+1, #positions do
            for k = j+1, #positions do
                local A, B, C = positions[i], positions[j], positions[k]
                local posA, posB = trilaterate(A, B, C)
                if posA and posB then
                    
                elseif posA then
                    return posA
                else

                end
            end
        end
    end
    return nil
end
