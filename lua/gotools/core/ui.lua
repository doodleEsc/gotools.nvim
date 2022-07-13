local Menu = require("nui.menu")
local NuiText = require("nui.text")
local event = require("nui.utils.autocmd").event

local M = {}

local function on_submit_factory(spec)
    return function(item)
        local index = item:get_id()
        local cb = spec[index][2]
        local ok, _ = pcall(cb)
        if not ok then
            vim.notify("Failed to run selected function", vim.log.levels.ERROR)
        end
    end
end

local function lines_factory(spec)
    local lines = {}
    for i, item in ipairs(spec) do
        local text = string.format("%d: %s", i, item[1])
        table.insert(lines, Menu.item(NuiText(text)))
    end
    return lines
end

local function adjust_size(spec, opts)
    if type(spec) ~= "table" then
        vim.notify("unsupported menu item, table needed", vim.log.levels.ERROR)
        return
    end

    local max_height = #spec * 2
    local max_width = 0
    for _, item in ipairs(spec) do
        if #item[1] >= max_width then
            max_width = #item[1]
        end
    end

    max_width = max_width * 2
    opts.size = {
        width = max_width,
        height = max_height
    }

end

M.show = function(spec, opts, keymap)
    adjust_size(spec, opts)
    local menu = Menu(opts, {
        keymap = keymap,
        lines = lines_factory(spec),
        on_submit = on_submit_factory(spec),
    })
    menu:mount()
    menu:on(
        event.BufLeave,
        function()
            menu:unmount()
        end,
        { once = true }
    )
end

return M
