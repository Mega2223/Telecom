NetworkDatagram = NetworkDatagram or require('NetworkDatagram')

DATAGRAM_TYPES = {
    MESSAGE_DATAGRAM = "MESSAGE_DATAGRAM",
    PING_DATAGRAM = "PING_DATAGRAM",
    DISCOVERY_DATAGRAM = "DISCOVERY_DATAGRAM",
    MSG_CONFIRMATION_DATAGRAM = "MSG_CONFIRMATION_DATAGRAM",
    LOST_DATAGRAM_ALERT = "LOST_DATAGRAM_ALERT",
    ASK_ENDPOINTS_DATAGRAM = "ASK_ENDPOINTS_DATAGRAM"
}

function ParsedDatagram(str)
    local time_to_die, route, type, message = ParseDatagramComponents(str)
    
end

function MessageDatagram(content, route, routerObject, time_to_die, alert_on_die)
    alert_on_die = alert_on_die or false
    return NetworkDatagram(content, route, "MESSAGE_DATAGRAM", routerObject, time_to_die, 
    function(self) --update function
        return MessageDatagram(self.content, self.route, self.routerObject, self.time_to_die - 1)
    end, 
    function(self) -- die function
        if alert_on_die then
            --- DIE FUNC
        end
    end
    )
end

function PingDatagram(route, routerObject, time_to_die)
    return NetworkDatagram('',route,"PING_DATAGRAM",routerObject,time_to_die,
    function(self) -- update funct
        return PingDatagram(route, routerObject, time_to_die - 1)
    end
    )
end

function DiscoveryDatagram(id,routerObject,is_reply)
    return NetworkDatagram(id,nil,'DISCOVERY_DATAGRAM',routerObject,0,nil,nil,
        function (self)
            if is_reply then
                self.routerObject:transmit(
                    self.id + "REPLY" + routerObject.name
                )
            end
        end
    )
end

return ParsedDatagram