GLOBAL_DEBUG_LEVEL = 0 -- per object?

DEBUG_CONSTANTS = {
    NOTHING = 0,
    IMPORTANT = 1,
    PROCESSES = 2,
    PROCESS_LOGIC = 3,
    VERBOSE = 4
}

---@class StreamWriter
---@field write fun(self: StreamWriter, data: string)

---Creates a StreamWriter
---@param onWrite fun(self: StreamWriter, data: string) | nil what to do on write, prints by default
function StreamWriter(onWrite)
    ---@type StreamWriter
    return {
        write = onWrite or function(self, data) print(data) end
    }
end

function debugVerbose()
    --warning?
end