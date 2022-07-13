local M = {}
local Job = require "plenary.job"
local ts_utils = require "gotools.utils.ts"
local options = require("gotools").options
local input = require("gotools.ui.input")

M.add_input = function()
    input.show(nil, options)
end

M.add = function(...)
    print(...)
end

M.remove = function()
end

M.actions = {
    ["Add tags"] = M.add_input,
    ["Remove tags"] = M.remove,
}

return M
