local utils = {}

local os_name = vim.loop.os_uname().sysname
local is_windows = os_name == "Windows" or os_name == "Windows_NT"

utils.sep = function()
  if is_windows then
    return "\\"
  end
  return "/"
end

return utils
