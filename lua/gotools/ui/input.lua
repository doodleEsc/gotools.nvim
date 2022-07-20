local Input = require("nui.input")
local event = require("nui.utils.autocmd").event

local M = {}

M.OPTS = {
    ui = {
        relative = "cursor",
        position = {
            row = 1,
            col = 0,
        },
        size = {
            width = 20,
        },
        border = {
            padding = { 0, 1 },
            text = {
                top = "Tag Type",
                top_align = "left",
            },
        },
    }
}

local function adjust_opts(callback, opts)
    if type(callback) ~= "function" then
        vim.notify("unsupported input, function needed", vim.log.levels.ERROR)
        return
    end

    M.OPTS = vim.tbl_deep_extend("force", M.OPTS, opts)
end

M.show = function(callback, opts)
    adjust_opts(callback, opts)
    local input = Input(M.OPTS.ui, {
        prompt = " ",
        on_submit = function(value)
            local ok, _ = pcall(callback, value)
            if not ok then
                vim.notify("Failed to run function", vim.log.levels.ERROR)
            end
        end,
    })
    input:map("i", "<Esc>", input.input_props.on_close, { noremap = true })
    input:map("i", "<C-c>", input.input_props.on_close, { noremap = true })
    input:mount()
    input:on(event.BufLeave, function()
        input:unmount()
    end)
end

return M
