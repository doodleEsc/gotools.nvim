local M = {}
local Job = require "plenary.job"
local ts_utils = require "gotools.utils.ts"
local utils = require "gotools.utils"
local options = require("gotools").options
local gomodifytags = options.tools.gomodifytags.bin or "gomodifytags"

local function modify(...)
    local fpath = vim.fn.expand "%"
    local cmd_args = {
        "-format", "json",
        "-file", fpath,
        "-w"
    }
    local arg = { ... }
    for _, v in ipairs(arg) do
        table.insert(cmd_args, v)
    end
    local res_data
    Job:new({
        command = gomodifytags,
        args = cmd_args,
        on_exit = function(data, retval)
            if retval ~= 0 then
                vim.notify(
                    "command 'gomodifytags " .. unpack(cmd_args) .. "' exited with code " .. retval,
                    vim.log.levels.ERROR
                )
                return
            end
            vim.inspect(data:result())
            res_data = data:result()
        end,
    }):sync()

    local tagged = vim.json.decode(table.concat(res_data))
    if tagged.errors ~= nil
        or tagged.lines == nil
        or tagged["start"] == nil
        or tagged["start"] == 0
    then
        vim.notify("failed to set tags " .. vim.inspect(tagged), "error")
    end
    for i, v in ipairs(tagged.lines) do
        tagged.lines[i] = utils.rtrim(v)
    end
    vim.api.nvim_buf_set_lines(
        0,
        tagged.start - 1,
        tagged.start - 1 + #tagged.lines,
        false,
        tagged.lines
    )
    vim.cmd[[write]]
end

local function get_struct(position)
    local pos = position or vim.api.nvim_win_get_cursor(0)
    local ns = ts_utils.get_struct_node_at_pos(unpack(pos))
    if ns == nil or ns == {} then
        return false, nil
    end

    return true, ns.name
end

local function get_field(position)
    local pos = position or vim.api.nvim_win_get_cursor(0)
    local ns = ts_utils.get_field_node_at_pos(unpack(pos))
    if ns == nil or ns == {} then
        return false, nil
    end

    return true, ns.name
end

local show = function(on_confirm)
    local opts = { prompt = '➤ ', label = 'Tag' }
    vim.ui.input(opts, on_confirm)
end

M.add = function(...)
    local arg = ...
    if arg == nil then return end

    local cmd_args = {}
    -- check struct
    local ok, struct = get_struct()
    if not ok then
        return
    end
    table.insert(cmd_args, "-struct")
    table.insert(cmd_args, struct)

    -- check field
    local ok, field = get_field()
    if ok then
        table.insert(cmd_args, "-field")
        table.insert(cmd_args, field)
    end

    table.insert(cmd_args, "-add-tags")

    if #arg == 0 or arg == "" then
        arg = "json"
    end
    table.insert(cmd_args, arg)

    modify(unpack(cmd_args))
end

M.remove = function(...)
    local arg = ...
    if arg == nil then return end

    local cmd_args = {}

    -- check struct
    local ok, struct = get_struct()
    if not ok then
        return
    end
    table.insert(cmd_args, "-struct")
    table.insert(cmd_args, struct)

    -- check field
    local field_ok, field = get_field()
    if field_ok then
        table.insert(cmd_args, "-field")
        table.insert(cmd_args, field)
    end

    local arg = ...
    if #arg == 0 or arg == "" then
        table.insert(cmd_args, "-clear-tags")
    else
        table.insert(cmd_args, "-remove-tags")
    end
    table.insert(cmd_args, arg)

    modify(unpack(cmd_args))
end

M.add_tags = function()
    show(M.add)
end

M.remove_tags = function()
    show(M.remove)
end

M.generate_actions = function(params)
    local position = { params.row, params.col }
    local ok, _ = get_struct(position)
    if not ok then
        return {}
    end

    local actions = {
        ["Add Tag"] = M.add_tags,
        ["Del Tag"] = M.remove_tags,
    }

    return actions
end

return M
