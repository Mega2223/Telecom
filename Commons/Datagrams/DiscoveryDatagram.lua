require('Commons.Datagrams.Datagram')

-- The discovery datagram is made for routers to find out adjacent routers through a ping

---@param self DiscoveryDatagram
local function toString(self)
    return "[DDT-" .. self.time_to_die .. "-" ..
    "(" .. self.route ..")" ..
    "-" .. self.type .. -- Redundante
    "-(" .. tostring(self.isReply) .. ")]"
end

---@class DiscoveryDatagram
---@field time_to_die integer
---@field isReply boolean
---@field broadcaster_name string stored in the Route field
---@field toString fun(self: DiscoveryDatagram): string
---@field route string

---@param time_to_die integer
---@param isReply boolean
---@param broadcaster_name string
---@return DiscoveryDatagram
function DiscoveryDatagram(time_to_die,isReply,broadcaster_name)
    if not time_to_die or isReply == nil or not broadcaster_name then
        error('Could not make DiscoveryDatagram object due to missing params: '..
            tostring(time_to_die) .. '|' .. tostring(isReply) .. '|' .. tostring(broadcaster_name), 2
        )
    end
    ---@type DiscoveryDatagram
    return {
        time_to_die = time_to_die,
        isReply = isReply,
        type = 'DiscoveryDatagram',
        route = broadcaster_name,
        broadcaster_name = broadcaster_name,
        toString = toString
    }
end

local function parseDiscoveryDatagram(data)
    local time_to_die, broadcaster_name, type, isReply = string.match(data,"%[DDT%-(%d+)%-%((.*)%)%-(%w+)%-%((.*)%)%]")
    if not time_to_die then return false end
    time_to_die = tonumber(time_to_die)
    isReply = isReply ~= 'false'
    return time_to_die, broadcaster_name, isReply
end

---@param data string
---@param router Router
---@return boolean
local function onMessageReceived(data, router)
    local time_to_die, broadcaster_name, isReply = parseDiscoveryDatagram(data)
    if not time_to_die then return false end
    if isReply then
        table.insert(
            router.memory.adjacent_routers, broadcaster_name
        )
    else
        local answer = DiscoveryDatagram(1,true,router.configs.name)
        router:transmit(answer:toString())
    end
    return true
end

local function onDie()
    -- Do nothing
end

---@type DatagramParser
local discovery = {
    onDie = onDie,
    onMessageReceived = onMessageReceived,
    type = 'DiscoveryDatagramParser'
}

table.insert(NETWORK_DATAGRAM_PROT,discovery)

return DiscoveryDatagram