local M = {}
local Job = require "plenary.job"
local ts_utils = require "gotools.utils.ts"
local options = require("gotools").options
local input = require("gotools.ui.input")

M.manage_tag = function()
    local spec = {
        { "Add Tag", M.add },
        { "Remove Tag", M.remove }
    }

    input.show(spec, options)
end

M.add = function(...)
    print(...)
end

M.remove = function(...)
    print(...)
end

M.actions = {
    ["Add Tag"] = M.add,
    ["Remove Tag"] = M.remove,
}

return M
