---@class KnownNeighbor
---@field last_updated integer
---@field name string

---@param name string
---@param last_updated integer
---@return KnownNeighbor
function KnownNeighbor(name, last_updated)
    ---@type KnownNeighbor
    return {
        name = name,
        last_updated = last_updated
    }
end