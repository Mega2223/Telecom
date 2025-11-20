require('Network.Wrapper.ModemWrapper')
require('Network.Router')

wrapper = ModemWrapper(
    Router()
)

wrapper:begin()