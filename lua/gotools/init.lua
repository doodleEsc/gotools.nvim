local utils = require("gotools.utils")
local path = require "mason-core.path".bin_prefix()

local M = {}


local function concat_bin_path(dir, bin)
    return dir .. utils.sep() .. bin
end

local DEFAULT = {
    gotests = {
        bin = concat_bin_path(path, "gotests"),
        test_template = nil,
        test_template_dir = nil,
        verbose = true,
    }
}

M.options = {}

M.setup = function(opts)
    M.options = vim.tbl_deep_extend("force", DEFAULT, opts or {})
end

M.code_actions = require("gotools.code_actions")

return M
