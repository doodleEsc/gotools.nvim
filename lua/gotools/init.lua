local M = {}

local DEFAULT = {
    gotests = {
        bin = "gotests",
        test_template = nil,
        test_template_dir = nil,
        win_opts = {
            prompt = "Select An Action",
            kind = 'gotools'
        }
    },
    gomodifytags = {
        bin = "gomodifytags",
        skip_unexported = true,
        win_opts = {
            prompt = "Tag:",
            kind = 'gotools'
        }
    },
    impl = {
        bin = "impl",
        win_opts = {
            prompt = "Select An Action",
            kind = 'gotools'
        }
    }
}

M.options = {}

M.setup = function(opts)
    M.options = vim.tbl_deep_extend("force", DEFAULT, opts or {})
end

M.code_actions = require("gotools.code_actions")

return M
