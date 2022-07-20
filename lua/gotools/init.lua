local M = {}

local DEFAULT = {
    ui = {
        border = {
            style = "single",
        },
        win_options = {
            winhighlight = "Normal:Normal,FloatBorder:Normal",
        },
    },
    keymap = {
        focus_next = { "j", "<Down>" },
        focus_prev = { "k", "<Up>" },
        close = { "<Esc>", "<C-c>", "q" },
        submit = { "<CR>" },
    },
    tools = {
        gotests = {
            bin = "gotests",
            test_template = nil,
            test_template_dir = nil,
            verbose = true,
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
