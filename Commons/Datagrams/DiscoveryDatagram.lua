require('Commons.Datagrams.Datagram')

-- The discovery datagram is made for routers to find out adjacent routers through a ping

NETWORK_DATAGRAM_PROT = NETWORK_DATAGRAM_PROT or {}

---@param self DiscoveryDatagram
---@return string
---@nodiscard
local function toString(self)
    --[[return "[DDT-" .. self.time_to_die .. "-" ..
    "(" .. self.route ..")" ..
    "-" .. self.type .. -- Redundante
    "-(" .. tostring(self.isReply) .. ")]"
    ]]
    return string.format("[DDT-(%s)-(%s)-(%s)]",self.asker_name,self.replier_name,self.identifier)
end

---@class DiscoveryDatagram
---@field isReply boolean
---@field asker_name string stored in the Route field
---@field replier_name string | 'nil'
---@field identifier string
---@field toString fun(self: DiscoveryDatagram): string
---@field type 'DiscoveryDatagram'

---@param asker_name string
---@param replier_name string
---@param identifier string
---@return DiscoveryDatagram
function DiscoveryDatagram(asker_name, replier_name, identifier)
    if not asker_name or not replier_name or not identifier then
        error('Could not make DiscoveryDatagram object due to missing params: '..
            tostring(asker_name) .. '|' .. tostring(replier_name) .. '|' .. tostring(identifier), 2
        )
    end
    ---@type DiscoveryDatagram
    return {
        asker_name = asker_name,
        replier_name = replier_name,
        identifier = identifier,
        toString = toString,
        isReply = replier_name ~= 'nil',
        type = 'DiscoveryDatagram'
    }
end

---@param data string
---@return string, string, string
local function parseDiscoveryDatagram(data)
    --local time_to_die, broadcaster_name, type, isReply = string.match(data,"%[DDT%-(%d+)%-%((.*)%)%-(%w+)%-%((.*)%)%]")
    local ask, reply, identifier = string.match(data,"%[DDT%-%((.+)%)%-%((.+)%)%-%((.+)%)%]")
    return ask, reply, identifier
end

---@param data string
---@param router Router
---@return boolean
local function onMessageReceived(data, router)
    local asker_name, replier_name, identifier = parseDiscoveryDatagram(data)
    if not asker_name then return false end
    --print(router.configs.name, 'rc', asker_name)
    local datagram = DiscoveryDatagram(asker_name,replier_name,identifier)
    if datagram.isReply and datagram.asker_name == router.configs.name then
        --router.memory.adjacent_routers[replier_name] = KnownNeighbor(datagram.replier_name,router.current_time_milis)
        router.memory:updateAdjacecy(datagram.replier_name,router.current_time_milis)
        --print(data,router.configs.name .. ' AWARE')
    elseif datagram.asker_name ~= router.configs.name and not datagram.isReply then
        local answer = DiscoveryDatagram(asker_name,router.configs.name,identifier)
        --print(data, '->', answer:toString())
        router:transmit(answer:toString(),2500+math.random(5000))
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