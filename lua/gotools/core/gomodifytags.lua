local M = {}
local Job = require "plenary.job"
local tsutil = require "gotools.ts"
local util = require "gotools.util"
local options = require("gotools").options
local gomodifytags = options.tools.gomodifytags.bin or "gomodifytags"
local input_opts = options.input_opts
local skip_unexported = options.tools.gomodifytags.skip_unexported

local function modify(...)
    local fpath = vim.fn.expand "%"
    local cmd_args = {
        "-format", "json",
        "-file", fpath,
        "-w",
    }

    if skip_unexported then
        table.insert(cmd_args, "-skip-unexported")
    end
    local arg = { ... }
    for _, v in ipairs(arg) do
        table.insert(cmd_args, v)
    end
    print(vim.inspect(cmd_args))
    Job:new({
        command = gomodifytags,
        args = cmd_args,
        on_exit = function(data, retval)
            if retval ~= 0 then
                vim.notify(
                    "command 'gomodifytags' exited with code " .. retval,
                    vim.log.levels.ERROR
                )
                return
            end
            local res_data = data:result()
            local tagged = vim.json.decode(table.concat(res_data))
            if tagged.errors ~= nil
                or tagged.lines == nil
                or tagged["start"] == nil
                or tagged["start"] == 0
            then
                vim.notify("failed to set tags " .. vim.inspect(tagged), "error")
            end
            for i, v in ipairs(tagged.lines) do
                tagged.lines[i] = util.rtrim(v)
            end
            vim.schedule(function()
                vim.api.nvim_buf_set_lines(
                    0,
                    tagged.start - 1,
                    tagged.start - 1 + #tagged.lines,
                    false,
                    tagged.lines
                )
                vim.cmd [[write]]
            end)
        end,
    }):start()
end

local function get_struct()
    -- local pos = position or vim.api.nvim_win_get_cursor(0)
    local ns = tsutil.get_struct_node_at_cursor()
    if ns == nil or ns == {} then
        return nil
    end

    return ns.name
end

local function get_field()
    local ns = tsutil.get_struct_field_node_at_cursor()
    if ns == nil or ns == {} then
        return nil
    end

    return ns.name
end

local show = function(on_confirm)
    local opts = input_opts
    opts.label = "Tag"
    vim.ui.input(opts, on_confirm)
end

M.add_tags = function(...)
    local arg = ...
    if arg == nil then return end

    local cmd_args = {}
    -- check struct
    local struct = get_struct()
    if struct == nil then
        return
    end
    table.insert(cmd_args, "-struct")
    table.insert(cmd_args, struct)

    -- check field
    local field = get_field()
    if field ~= nil then
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

M.add_options = function(...)
    local arg = ...
    if arg == nil then return end

    local cmd_args = {}
    -- check struct
    local struct = get_struct()
    if struct == nil then
        return
    end
    table.insert(cmd_args, "-struct")
    table.insert(cmd_args, struct)

    -- check field
    local field = get_field()
    if field ~= nil then
        table.insert(cmd_args, "-field")
        table.insert(cmd_args, field)
    end

    table.insert(cmd_args, "-add-options")

    if #arg == 0 or arg == "" then
        vim.notify("No options to be add")
        return
    end

    table.insert(cmd_args, arg)
    modify(unpack(cmd_args))
end

M.remove_options = function(...)
    local arg = ...
    if arg == nil then return end

    local cmd_args = {}
    -- check struct
    local struct = get_struct()
    if struct == nil then
        return
    end
    table.insert(cmd_args, "-struct")
    table.insert(cmd_args, struct)

    -- check field
    local field = get_field()
    if field ~= nil then
        table.insert(cmd_args, "-field")
        table.insert(cmd_args, field)
    end

    table.insert(cmd_args, "-remove-options")

    if #arg == 0 or arg == "" then
        vim.notify("No options to be remove")
        return
    end

    table.insert(cmd_args, arg)
    modify(unpack(cmd_args))
end

M.remove_tags = function(...)
    local arg = ...
    if arg == nil then return end

    local cmd_args = {}

    -- check struct
    local struct = get_struct()
    if struct == nil then
        return
    end
    table.insert(cmd_args, "-struct")
    table.insert(cmd_args, struct)

    -- check field
    local field = get_field()
    if field ~= nil then
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

M.show_add_tags = function()
    show(M.add_tags)
end

M.show_remove_tags = function()
    show(M.remove_tags)
end

M.show_add_options = function()
end

M.show_remove_options = function()
end


M.generate_actions = function(params)
    -- local struct = get_struct()
    -- if struct == nil then
    --     return {}
    -- end
    --
    local actions = {
        ["Add Tag"] = M.show_add_tags,
        ["Del Tag"] = M.show_remove_tags,
    }

    return actions
end

return M
