NetworkDatagram = NetworkDatagram or require('Objects.Layers.NetworkDatagram')

local function toString(self)
    return "[TDT-" .. "]"
end

function TransmissionDatagram(message, type)
    return{
        message = message,
        type = type,
        toString = toString
    }
end




return TransmissionDatagram