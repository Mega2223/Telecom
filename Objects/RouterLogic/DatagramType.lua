NetworkDatagram = NetworkDatagram or require('NetworkDatagram')

DATAGRAM_TYPES = {
    ROUTED_DATAGRAM = "MESSAGE_DATAGRAM",
    PING_DATAGRAM = "PING_DATAGRAM",
    CONFIRMATION_DATAGRAM = "CONFIRMATION_DATAGRAM",
    LOST_DATAGRAM_ALERT = "LOST_DATAGRAM_ALERT"
}

function MessageDatagram(content, route, routerObject, time_to_die)
    return NetworkDatagram(content, route, "MESSAGE_DATAGRAM", routerObject, time_to_die, 
    function(self) --update function
        return MessageDatagram(self.content, self.route, self.routerObject, self.time_to_die - 1)
    end, 
    function(self) -- die function
        
    end
)
end