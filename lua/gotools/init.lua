local M = {}

local DEFAULT = {
    tools = {
        gotests = {
            bin = "gotests",
            test_template = nil,
            test_template_dir = nil,
        },
        gomodifytags = {
            bin = "gomodifytags",
        }
    }
}

M.options = {}

M.setup = function(opts)
    M.options = vim.tbl_deep_extend("force", DEFAULT, opts or {})
end

M.code_actions = require("gotools.code_actions")

return M
