---Definitions for the ClassicPeripheral's radio tower peripheral

---@class RadioPeripheral
---@field broadcast fun(msg: string)
---@field canBroadcast fun(): boolean
---@field getFrequency fun(): integer
---@field getHeight fun(): integer
---@field isValid fun(): boolean
---@field setFrequency fun(freq: integer)