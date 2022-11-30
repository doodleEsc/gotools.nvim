local tele_actions = require 'telescope.actions'
local Job = require "plenary.job"
local state = require 'telescope.actions.state'
local tele_actions_set = require 'telescope.actions.set'
local conf = require 'telescope.config'.values
local finders = require 'telescope.finders'
local make_entry = require "telescope.make_entry"
local pickers = require 'telescope.pickers'
local ts_utils = require "gotools.utils.ts"
local channel = require("plenary.async.control").channel
local tele_utils = require "telescope.utils"
local options = require("gotools").options
local impl = options.tools.impl.bin or "impl"


local M = {}

M.recv_style = ""

local function run(cmd_args)
    local job = Job:new({
        command = impl,
        args = cmd_args,
        on_exit = function(data, retval)
            if retval ~= 0 then
                vim.notify(
                    "command 'impl " .. unpack(cmd_args) .. "' exited with code " .. retval,
                    vim.log.levels.ERROR
                )
                return
            end
            vim.schedule(function()
                local content = data:result()
                local lnum = vim.fn.line("$")
                table.insert(content, 1, "")
                vim.fn.append(lnum, content)
                vim.api.nvim_win_set_cursor(0, { lnum + 1, 0 })
            end)
        end,
    })

    job:start()
end

local function get_struct(position)
    local pos = position or vim.api.nvim_win_get_cursor(0)
    local ns = ts_utils.get_struct_node_at_pos(unpack(pos))
    if ns == nil or ns == {} then
        return nil
    end

    return ns.name
end

local function get_package(pkg_dir)
    if pkg_dir == nil then
        return nil
    end
    local args = { "list" }
    local pkg = ""

    local job = Job:new({
        command = "go",
        args = args,
        cwd = pkg_dir,
        on_stdout = function(_, data)
            pkg = data
        end,
    })
    job:sync()

    return pkg
end

local function get_interface_name(entry)
    if entry.symbol_type ~= "Interface" then
        return nil
    end
    local pkg_dir = vim.fn.fnamemodify(entry.filename, ':p:h')
    local pkg = get_package(pkg_dir)
    if pkg == nil then
        return nil
    end
    return pkg .. "." .. entry.symbol_name
end

local function get_receiver()
    local struct = get_struct()
    if struct == nil then
        return nil
    end

    if #M.recv_style ~= 0 and M.recv_style == "struct" then
        return string.sub(struct, 1, 1) .. " " .. struct
    end

    if #M.recv_style ~= 0 and M.recv_style == "pointer" then
        return string.sub(struct, 1, 1) .. " " .. "*" .. struct
    end
    return nil
end

local function goimpl(entry)
    local cmd_args = { "-dir" }

    local dir = vim.fn.fnameescape(vim.fn.expand("%:p:h"))
    table.insert(cmd_args, dir)

    local recv = get_receiver()
    if recv == nil then
        vim.notify("No Struct Founded at Cursor Position")
        return
    end
    table.insert(cmd_args, recv)

    local iface = get_interface_name(entry)
    if iface == nil then
        vim.notify("No Interface Founded")
        return
    end
    table.insert(cmd_args, iface)

    run(cmd_args)
end

local function get_workspace_symbols_requester(bufnr, opts)
    local cancel = function() end
    return function(prompt)
        local tx, rx = channel.oneshot()
        cancel()
        _, cancel = vim.lsp.buf_request(bufnr, "workspace/symbol", { query = prompt }, tx)

        -- Handle 0.5 / 0.5.1 handler situation
        local err, res = rx()
        assert(not err, err)

        local locations = vim.lsp.util.symbols_to_items(res or {}, bufnr) or {}
        if not vim.tbl_isempty(locations) then
            locations = tele_utils.filter_symbols(locations, opts) or {}
        end
        return locations
    end
end

M.goimpl = function(opts)
    opts = opts or {}
    local curr_bufnr = vim.api.nvim_get_current_buf()
    local struct = get_struct()
    if struct == nil then
        vim.notify("No type identifier found under cursor", vim.log.levels.WARN)
        return
    end

    pickers.new(opts, {
        prompt_title = "Go Impl",
        finder = finders.new_dynamic {
            entry_maker = opts.entry_maker or make_entry.gen_from_lsp_symbols(opts),
            fn = get_workspace_symbols_requester(curr_bufnr, opts),
        },
        previewer = conf.qflist_previewer(opts),
        sorter = conf.generic_sorter(),
        attach_mappings = function(prompt_bufnr)
            tele_actions_set.select:replace(function(_, _)
                local entry = state.get_selected_entry()
                tele_actions.close(prompt_bufnr)
                if not entry then
                    return
                end
                goimpl(entry)
            end)
            return true
        end,
    }):find()
end

M.generate_actions = function(params)
    local position = { params.row, params.col }
    local struct = get_struct(position)
    if struct == nil then
        return {}
    end

    local actions = {
        ["Impl Interface"] = function()
            local opts = options.impl
            M.recv_style = "struct"
            M.goimpl(opts)
        end,
        ["Impl Interface In Pointer"] = function()
            local opts = options.impl
            M.recv_style = "pointer"
            M.goimpl(opts)
        end,
    }

    return actions
end

return M
