local utils = require("gotools.utils")
local default_bin_dir = vim.fn.stdpath("data") .. utils.sep() .. "mason" .. utils.sep() .. "bin"
local M = {}

M.options = {}

local function concat_bin_path(dir, bin)
    return default_bin_dir .. utils.sep() .. bin
end

M.defaults = {
  bin_path = {
    gotests = concat_bin_path(default_bin_dir, "gotests"), 
    impl = concat_bin_path(default_bin_dir, "impl"), 
    gomodifiytags = concat_bin_path(default_bin_dir, "gomodifiytags"), 
  },
}

M.setup = function(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
