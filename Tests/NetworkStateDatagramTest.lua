require('Commons.Datagrams.NetworkStateDatagram')

local nsd = NetworkStateDatagram('RT-NIL')

print(nsd.data)
print(nsd:toString())
print(nsd:getAnswer('ANSWER :3'):toString())
print('whar')