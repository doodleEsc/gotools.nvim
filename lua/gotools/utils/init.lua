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

return utils
