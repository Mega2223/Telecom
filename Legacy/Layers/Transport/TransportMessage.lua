local function toString(self)
    return 'TR_MSG PR=[' .. self.protocol .. '] MSG=[' .. self.message ..']'
end

-- transport entity class? (as in the communications manager)

function TransportMessage(message, protocol)
    return {
        message = message,
        protocol = protocol,
        type = 'TransportMessage',
        toString = toString
    }
end

function getParsedTransportMessage(data)
    local protocol, message = string.match(data,"TR_MSG PR=%[(.+)] MSG=%[(.+)]")
    return TransportMessage(message, protocol)
end

return TransportMessage