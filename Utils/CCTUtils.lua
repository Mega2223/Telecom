---@diagnostic disable: need-check-nil
---@param path string
---@return string
function getFileOrMakeEmpty(path)
    if not fs.exists(path) then
        local f = fs.open(path, "w")
        f.write("")
        f.close()
    end
    
    local f = fs.open(path, "r")
    local r = f.readAll()
    f.close()
    return r or ''
end