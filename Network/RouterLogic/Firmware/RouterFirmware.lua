-- Abstract class that represents any implementation of router logic

---@class RouterFirmware
---@field transmitMessage fun(self: RouterFirmware, message: string): boolean
---@field router Router
---@field begin fun(self: RouterFirmware)
---@field iteration ?integer
---@field firmware_type_name string
