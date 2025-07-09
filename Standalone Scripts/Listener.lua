monitor = peripheral.find('monitor')
modem = peripheral.find('modem')

modem.open(1)
term.redirect(monitor)

while true do
    os.setAlarm(.01)
    local event, a, b, c, d, e, f, g = os.pullEvent()
    if event == 'modem_message' then
        print(event,a,b,c,d,e,f,g)
    end
end