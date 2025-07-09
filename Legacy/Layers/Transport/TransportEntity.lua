TransportMessage = TransportMessage or require('TransportMessage')

function TransportEntity(onMessageReceived,type_name)
    return {
        onMessageReceived = onMessageReceived,
        type = type_name
    }
end

function RouterTransportEntity(router_object, router_application_object)
    TransportEntity(
        function (self, msg)
            local msg = getParsedTransportMessage(msg)
            router_application_object:onMessageReceived(msg)
        end,
        "RouterTransportEntity"
    )
end