require('Telecom')
require('Network.EndpointLogic.Endpoint')
require('Network.EndpointLogic.Firmware.RadioEndpoint')

FREQUENCY = 2223

endpoint_r = RadioEndpoint(FREQUENCY)

endpoint_r:begin()