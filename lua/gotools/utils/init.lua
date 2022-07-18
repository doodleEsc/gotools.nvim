local utils = {}

local os_name = vim.loop.os_uname().sysname
local is_windows = os_name == "Windows" or os_name == "Windows_NT"

utils.sep = function()
    if is_windows then
        return "\\"
    end
    return "/"
end

utils.empty = function(t)
    if t == nil then
        return true
    end
    return next(t) == nil
end

utils.split = function(str, delimiter)
    local result = {};
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match);
    end
    return result;
end

---@param s string
---@return string
utils.rtrim = function(s)
    local n = #s
    while n > 0 and s:find("^%s", n) do
        n = n - 1
    end

    return s:sub(1, n)
end

return utils
