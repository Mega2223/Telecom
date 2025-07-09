if DiscoveryDatagram then return DiscoveryDatagram end

NETWORK_DATAGRAM_PROT = NETWORK_DATAGRAM_PROT or {}

-- The discovery datagram is made for routers to find out adjacent routers through a ping
local function toString(self)
    --print("SELF = ")
    --print(self)
    --the = self
    --print(textutils.serialise(self))
    return "[NDT-" .. self.time_to_die .. "-" ..
    "(" .. self.route ..")" ..
    "-" .. self.type .. -- Redundante
    "-(" .. tostring(self.reply_bool) .. ")]"
end

function DiscoveryDatagram(time_to_die,reply_bool,broadcaster_name)
    return {
        time_to_die = time_to_die,
        reply_bool = reply_bool,
        type = 'DiscoveryDatagram',
        route = broadcaster_name,
        toString = toString
    }
end

local function parseDiscoveryDatagram(data)
    local time_to_die, broadcaster_name, type, reply_bool = string.match(data,"%[DDT%-(%d+)%-%((.*)%)%-(%w+)%-%((.*)%)%]")
    if not time_to_die then return false end
    time_to_die = tonumber(time_to_die)
    reply_bool = reply_bool == 'true'
    return time_to_die, broadcaster_name, reply_bool
end

local function onMessageReceived(data, router)
    local time_to_die, broadcaster_name, reply_bool = parseDiscoveryDatagram(data)
    if not time_to_die then return false end
    if reply_bool then
        table.insert(
            router.memory.adjacent_routers, broadcaster_name
        )
    else
        local answer = DiscoveryDatagram(1,true,router.name)
        router.transmit(answer:toString())
    end
end

local function onDie()
    -- What to do in case the message dies in the net
end

local discovery = {
    onDie = onDie,
    onMessageReceived = onMessageReceived
}

table.insert(NETWORK_DATAGRAM_PROT,discovery)

return DiscoveryDatagram