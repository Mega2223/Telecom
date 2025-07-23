require('Commons.Datagrams.ConnectionsDatagram')
require('Network.Wrapper.DebugWrapper')

local dat = ConnectionsDatagram(10,"(RT-12)(RT-13)","RT-13","(RT-14)(RT-11)(RT-15)",3)

print(dat:toString())
print(ParsedConnectionsDatagram(dat:toString()):toString())

local rlist = ''
for i = 1, #dat.routers_traveled do
    rlist = rlist .. ' ' .. dat.routers_traveled[i]
end

r = Router({
    name = 'RT-13'
})
d = DebugWrapper(r)

local msg = dat:toString()

--print(r.name)

for i = 1, #NETWORK_DATAGRAM_PROT do
    local b = NETWORK_DATAGRAM_PROT[i].onMessageReceived(msg,r)
    print(NETWORK_DATAGRAM_PROT[i].type .. ': ' .. tostring(b))
end

local dat_2 = ConnectionsDatagram(10,"(RT-12)","RT-12","(RT-13)",5)
local dat_3 = ConnectionsDatagram(10,"(RT-14)","RT-14","(RT-15)(RT-12)",6)

for i = 1, #NETWORK_DATAGRAM_PROT do
    NETWORK_DATAGRAM_PROT[i].onMessageReceived(dat_2:toString(),r)
    NETWORK_DATAGRAM_PROT[i].onMessageReceived(dat_3:toString(),r)
end

print('memory:')
print(r.memory:toString())