--- gives information about the routers a given router is connected to
ROUTER_APP_PROT = ROUTER_APP_PROT or {}

local function parse(data_str)

end

local function create(origin_router, connected_routers)
    
end

local function process(router_object)

end

function LocalConnectionInfoDatagram(origin_router, connected_routers)
    local connections = {}
    local i = 1

    while connected_routers[i] do
        connections[i] = connected_routers[i]
        i = i + 1
    end

    return {
        origin_router = origin_router,
        connected_routers = connections
    }
end

function LocalConnectionInfoParser()
    return {
        parse = parse,
        create = create,
        process = process
    }
end

ROUTER_APP_PROT['LocalConnectionInfo'] = LocalConnectionInfoParser()