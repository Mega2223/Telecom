require('Network.Wrapper.RouterWrapper')
require('Network.Router')

wrapper = RouterWrapper(
    Router(
        {name = 'RT-'..tostring(math.random(10000))}
    )
)

wrapper:begin()