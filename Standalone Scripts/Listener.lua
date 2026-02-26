monitor = peripheral.find('monitor')
modem = peripheral.find('modem')

monitor.setTextScale(.5)
modem.open(1)
term.redirect(monitor)
term.setCursorPos(1,1)
term.clear()

while true do
    os.setAlarm(.01)
    local event, a, b, c, d, e, f, g = os.pullEvent()
    if event == 'modem_message' then
        print(a,b,c,d,e,f,g)
    end
end