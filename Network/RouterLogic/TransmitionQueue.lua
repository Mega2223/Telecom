
---@class TransmitionQueue
---@field messages table<integer,ScheduledMessage>
---@field scheduleMessage fun(self:TransmitionQueue, message: string,time: integer | nil)
---@field refresh fun(self:TransmitionQueue, time: integer, max_transmitions: integer | nil)
---@field router Router

---@class ScheduledMessage
---@field data string
---@field transmition_time integer

---@param data string
---@param transmition_time ?integer
---@return ScheduledMessage
function ScheduledMessage(data, transmition_time)
    return {
        data = data,
        transmition_time = transmition_time or 0
    }
end

---@param router Router
---@return TransmitionQueue
function TransmitionQueue(router)
    ---@type TransmitionQueue
    return {
        messages = {},
        router = router,
        scheduleMessage =function (self, message, time)
            time = time or self.router.current_time_milis
            table.insert(self.messages, ScheduledMessage(message,time))
        end,
        refresh = function (self, time, max_transmitions)
            for key, message in pairs(self.messages) do
                if time >= message.transmition_time then
                    local success = self.router.wrapper:transmitMessage(message.data)
                    if success then
                        max_transmitions = max_transmitions - 1
                        self.messages[key] = nil
                    end
                end
                if max_transmitions <= 0 then break end
            end
        end
    }
end