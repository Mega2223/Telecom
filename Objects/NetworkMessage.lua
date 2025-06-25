local function nextRouter(self)
    
end

function NetworkMessage(content, time_to_die, route)
    return {
        content = content,
        time_to_die = time_to_die,
        route = route,
        next = nextRouter
    }
end