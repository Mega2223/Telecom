require('Telecom')
require('Network.RouterLogic.Firmware.RadioRouter')

shell.run("cp Telecom/Startup/RadioRouterStartup.lua startup.lua")

radio_r = RadioRouter(2223)
radio_r:begin()