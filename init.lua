package.path = package.path .. ";Telecom/?;Telecom/?.lua"

---@type fun(msg: string)
STD_OUT = print
---@type fun(msg: string)
STD_ERR = function(data)
    if os and term and fs then
        local col = term.getTextColor()
        term.setTextColor(colors.red)
        print(data)
        term.setTextColor(col)
        local f = fs.open("error.txt", "w")
        if not f then return end
        -- f.write(data) uer
        -- f.close()
    else
        print(data)
    end
end
---@type fun(msg: string)
STD_WARN = function(data)
    if os and term and fs then
        local col = term.getTextColor()
        term.setTextColor(colors.yellow)
        print(data)
        term.setTextColor(col)
    else
        print(data)
    end
end

---@type fun(msg: string)
STD_EVENT = print