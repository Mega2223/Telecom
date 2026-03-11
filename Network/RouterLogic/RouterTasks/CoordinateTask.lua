require('Network.RouterLogic.RouterTasks.RouterTask')
require('Utils.Math.Vector')
require('Utils.CCTUtils.Trilaterate')

---@param router Router
---@param time integer
function doLogic(router, time)
    local pos = router.memory.position
    if pos or not term then return end -- needs CC:T trilateration

    STD_OUT('tryin\' to trilaterate')

    ---@type table<integer,RouterPosition>
    local known_positions = {}

    for name, network_rt in pairs(router.memory.network_state.network_routers) do
        local x, y, z, dist = network_rt.properties['x'], network_rt.properties['y'],
            network_rt.properties['z'], network_rt.properties['distance']

        if not (x and y and z and dist) then goto continue end
        local x, y, z, dist = tonumber(x), tonumber(y), tonumber(z), tonumber(dist)
        if not (x and y and z and dist) then goto continue end

        ---@type RouterPosition
        local r_pos = { x = x, y = y, z = z, dist = dist }
        table.insert(known_positions, r_pos)
        ::continue::
    end

    if #known_positions < 3 then
        STD_OUT('only ' .. #known_positions .. ' positions :(')
        return
    end
    
    local loc = getLocation(known_positions)
    if loc then
        STD_EVENT(string.format('found position: %.3f %.3f %.3f', loc.x, loc.y, loc.z))
        local x, y, z = loc.x, loc.y, loc.z
        router.memory.position = {
            x = x, y = y, z = z, dist = 0
        }
        -- error 'so pra vc saber'
        return
    end
    STD_OUT'FAILED TO TRILATERATE'
end

---@type RouterTask
local coord_task = {
    doLogic = doLogic
}

table.insert(ROUTER_TASKS, coord_task)