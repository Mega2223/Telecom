package.path = package.path .. ";Telecom/?;Telecom/?.lua"

require('Network.RouterLogic.Datagrams.RouterPropertiesDatagram')
require('Network.RouterLogic.Datagrams.DiscoveryDatagram')
require('Network.RouterLogic.Datagrams.EndpointNegotiationDatagram')
require('Network.RouterLogic.Datagrams.NetworkStateDatagram')

