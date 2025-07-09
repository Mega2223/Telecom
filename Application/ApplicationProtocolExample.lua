ROUTER_APP_PROT = ROUTER_APP_PROT or {}

local function parse(data_str)
    -- returns data from the datagram, returns FALSE if not possible
end

local function create()
    -- creates a string given the data for the datagram
end

local function process(router_object)
    -- takes action upon receiving said package
end

function ApplicationProtocolExampleParser()
    return {
        parse = parse,
        create = create,
        process = process,
        type = 'ApplicationProtocolExample'
    }
end

ROUTER_APP_PROT['ApplicationProtocolExample'] = ApplicationProtocolExampleParser()