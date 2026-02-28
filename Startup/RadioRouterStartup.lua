---@diagnostic disable-next-line: different-requires
require('Telecom')
require('Network.RouterLogic.Firmware.RadioRouter')

radio_r = RadioRouter(2223)
radio_r:begin()