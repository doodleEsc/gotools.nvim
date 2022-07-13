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
                top = " Tag Type ",
                top_align = "left",
            },
        },
    }
}

local function adjust_opts(spec, opts)
    if type(spec) ~= "table" then
        vim.notify("unsupported input, table needed", vim.log.levels.ERROR)
        return
    end

    M.OPTS = vim.tbl_deep_extend("force", M.OPTS, opts)
end

M.show = function(spec, opts)
    adjust_opts(spec, opts)
    local input = Input(M.OPTS.ui, {
        prompt = "> ",
        on_submit = function(value)
            print("Value submitted: ", value)
        end,
    })
    input:map("n", "<Esc>", input.input_props.on_close, { noremap = true })
    input:mount()
    input:on(event.BufLeave, function()
        input:unmount()
    end)
end

return M
