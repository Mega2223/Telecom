-- This file is a template for datagram types

---@type table<string, DatagramParser>
NETWORK_DATAGRAM_PROT = NETWORK_DATAGRAM_PROT or {}

-- This is ran inside of the router logic

local function onMessageReceived(msg, router)
    -- Action taken upon an router receiving this datagram
    -- Returns false if message does not parse into this type of datagram
end

local function onDie()
    -- What to do in case the message dies in the net
end

local template_parser = {
    onDie = onDie,
    onMessageReceived = onMessageReceived,
    type = 'TemplateDatagramParser'
}

---@class DatagramParser
---@field onMessageReceived fun(msg: string, router: Router): boolean | nil
---@field onDie fun(): nil
---@field type string

table.insert(NETWORK_DATAGRAM_PROT,template_parser)