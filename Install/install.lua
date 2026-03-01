PATHS = [[
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/gen_paths.sh-->./gen_paths.sh
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/init.lua-->./init.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Install/paths.lua-->./Install/paths.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Install/setup.lua-->./Install/setup.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/LICENSE-->./LICENSE
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/CommonLogic/akljdlksa]-->./Network/CommonLogic/akljdlksa]
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/EndpointLogic/EndpointConfig.lua-->./Network/EndpointLogic/EndpointConfig.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/EndpointLogic/Endpoint.lua-->./Network/EndpointLogic/Endpoint.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/EndpointLogic/EndpointMemory.lua-->./Network/EndpointLogic/EndpointMemory.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/EndpointLogic/EndpointNegotiationDatagram.lua-->./Network/EndpointLogic/EndpointNegotiationDatagram.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/EndpointLogic/Protocol.lua-->./Network/EndpointLogic/Protocol.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/RouterLogic/ConnectionManager/ConnectionManager.lua-->./Network/RouterLogic/ConnectionManager/ConnectionManager.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/RouterLogic/Datagrams/DiscoveryDatagram.lua-->./Network/RouterLogic/Datagrams/DiscoveryDatagram.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/RouterLogic/Datagrams/EndpointNegotiationDatagram.lua-->./Network/RouterLogic/Datagrams/EndpointNegotiationDatagram.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/RouterLogic/Datagrams/NetworkStateDatagram.lua-->./Network/RouterLogic/Datagrams/NetworkStateDatagram.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/RouterLogic/Datagrams/RouterPropertiesDatagram.lua-->./Network/RouterLogic/Datagrams/RouterPropertiesDatagram.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/RouterLogic/Datagrams/TemplateDatagram.lua-->./Network/RouterLogic/Datagrams/TemplateDatagram.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/RouterLogic/Firmware/DebugWrapper.lua-->./Network/RouterLogic/Firmware/DebugWrapper.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/RouterLogic/Firmware/ModemRouter.lua-->./Network/RouterLogic/Firmware/ModemRouter.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/RouterLogic/Firmware/RadioRouter.lua-->./Network/RouterLogic/Firmware/RadioRouter.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/RouterLogic/Firmware/RouterFirmware.lua-->./Network/RouterLogic/Firmware/RouterFirmware.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/RouterLogic/NetworkState/KnownNetworkRouter.lua-->./Network/RouterLogic/NetworkState/KnownNetworkRouter.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/RouterLogic/NetworkState/NetworkState.lua-->./Network/RouterLogic/NetworkState/NetworkState.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/RouterLogic/Route.lua-->./Network/RouterLogic/Route.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/RouterLogic/RouterConfig.lua-->./Network/RouterLogic/RouterConfig.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/RouterLogic/Router.lua-->./Network/RouterLogic/Router.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/RouterLogic/RouterMemory/ConnectedEndpoint.lua-->./Network/RouterLogic/RouterMemory/ConnectedEndpoint.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/RouterLogic/RouterMemory/KnownNeighbor.lua-->./Network/RouterLogic/RouterMemory/KnownNeighbor.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/RouterLogic/RouterMemory/RouterMemory.lua-->./Network/RouterLogic/RouterMemory/RouterMemory.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Network/RouterLogic/TransmitionQueue.lua-->./Network/RouterLogic/TransmitionQueue.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/PROTOCOLS.txt-->./PROTOCOLS.txt
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/README.md-->./README.md
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Standalone-->./Standalone
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Scripts-->./Scripts
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Startup/RadioRouterStartup.lua-->./Startup/RadioRouterStartup.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Utils/CCTUtils.lua-->./Utils/CCTUtils.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Utils/Debug.lua-->./Utils/Debug.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Utils/Graph.lua-->./Utils/Graph.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Utils/TaskManager/Task.lua-->./Utils/TaskManager/Task.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Utils/TaskManager/TaskManager.lua-->./Utils/TaskManager/TaskManager.lua
https://raw.githubusercontent.com/Mega2223/Telecom/refs/heads/main/Utils/Utils.lua-->./Utils/Utils.lua
]]
PATHS = PATHS or -1

if PATHS == -1 then print("Could not find url paths, try running ./gen_paths.sh") return end

for url, loc in string.gmatch(PATHS, "([^\n]+)%-%->([^\n]+)\n") do
    loc = "Telecom/" .. loc
    print(string.format("installing %s at %s", url, loc))
    shell.run(string.format("wget \"%s\" \"%s\"",url,loc))
end

print("Library installed successfully :), check the Startup folder for startup profiles")
