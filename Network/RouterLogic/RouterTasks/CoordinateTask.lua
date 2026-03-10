require('Network.RouterLogic.RouterTasks.RouterTask')
require('Utils.Math.Vector')

---@param points table<integer, RouterPosition>
---@return number | nil
local function trilaterate(points)
    local A = points[1]
    if not A then return end

    local i = 1
    local B = points[1]
    while B.x == A.x and B.y == A.y and B.z == A.z and B ~= nil do
        B = points[i]
        i = i + 1
    end

    -- existe um plano cartesiano de possiveis coordenadas
end

---@param router Router
---@param time integer
function doLogic(router, time)
    local pos = router.memory.position
    if pos or not term then return end -- needs CC:T trilateration

    ---@type table<integer,RouterPosition>
    local known_positions = {}

    for name, network_rt in pairs(router.memory.network_state.network_routers) do
        local x, y, z, dist = network_rt.properties['x'], network_rt.properties['y'],
            network_rt.properties['z'], network_rt.properties['dist']
        
        if not (x and y and z and dist) then goto continue end
        local x, y, z, dist = tonumber(x), tonumber(y), tonumber(z), tonumber(dist)
        if not (x and y and z and dist) then goto continue end

        ---@type RouterPosition
        local r_pos = {x = x, y = y, z = z, dist = dist}
        table.insert(known_positions,r_pos)
        ::continue::
    end


end

---@type RouterTask
local coord_task = {
    doLogic = doLogic
}

table.insert(ROUTER_TASKS, coord_task)