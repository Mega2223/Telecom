-- Pra ser um padrão entre os firmwares de endpoint e routers
-- Ambos os firmwares devem puxar daqui

---@class CommFirmware
---@field transmitMessage fun(self: CommFirmware, message: string): boolean
---@field onMessageReceived fun(self: CommFirmware, message: string): boolean
---@field begin fun(self: CommFirmware)
---@field firmware_type string