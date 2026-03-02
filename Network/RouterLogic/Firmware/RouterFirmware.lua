-- Abstract class that represents any implementation of router logic

---@class RouterFirmware: CommFirmware
---@field transmitMessage fun(self: RouterFirmware, message: string): boolean
---@field onMessageReceived fun(self: RouterFirmware, message: string): boolean
---@field router Router
---@field begin fun(self: RouterFirmware)
---@field iteration ?integer
