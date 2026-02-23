---@diagnostic disable undefined-global
--- LUA plugin wont recognize CC functions for some reason
--- even tough they are defined by the plugin

---@param path string
---@return string
function getFileOrMakeEmpty(path)
    if not fs.exists(path) then
        local f = fs.open(path,"w")
        f.write("")
        f.close()
    end
    
    local f = fs.open(path, "r")
    local r = f.readAll()
    f.close()
    return r
end