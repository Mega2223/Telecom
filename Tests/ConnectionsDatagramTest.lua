require('Commons.Datagrams.ConnectionsDatagram')

local dat = ConnectionsDatagram(10,"(A)(B)(C)","ABC","(B)(A)")

print(dat:toString())
print(ParsedConnectionsDatagram(dat:toString()):toString())