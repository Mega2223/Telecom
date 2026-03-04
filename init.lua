package.path = package.path .. ";Telecom/?;Telecom/?.lua"

---@class OutputStream: function<string>

---@type OutputStream<string>
STD_OUT = print
---@type OutputStream<string>
STD_ERR = function (data)
    if os and term then
        local col = term.getTextColor()
        term.setTextColor(colors.red)
        print(data)
        term.setTextColor(col)
    end
end