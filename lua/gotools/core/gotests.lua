-- Table driven tests based on its target source files' function and method signatures.
-- https://github.com/cweill/gotests

local M = {}
local ts_utils = require "gotools.utils.ts"
local utils = require("gotools.utils")
local Job = require("plenary.job")
local options = require("gotools").options
local gotests = options.tools.gotests.bin or "gotests"

local run = function(args, extra)
    Job:new({
        command = gotests,
        args = args,
        on_exit = function(j, return_val)
            if return_val == 0 then
                if extra.test_funame ~= nil then
                    vim.notify("`" .. extra.test_funame .. "`" .. " generated in " .. extra.test_gofile)
                else
                    vim.notify("All test function generated in " .. extra.test_gofile)
                end
                vim.schedule(function()
                    vim.cmd("edit " .. extra.test_gocwd .. "/" .. extra.test_gofile)
                    if extra.test_funame ~= nil then
                        vim.fn.search(extra.test_funame)
                    end
                end)
            else
                vim.notify(j:result()[1], vim.log.levels.ERROR)
            end
        end
    }):start()
end

local get_test_gofile = function(gofile)
    if type(gofile) ~= "string" then
        vim.notify("Invalid File Type", "error")
        return
    end
    local sep = utils.sep()
    local results = utils.split(gofile, sep)
    local test_filename = results[#results]:gsub("%.", "_test.")
    return test_filename
end

local new_gotests_extra = function()
    local extra = {}
    extra.test_gocwd = vim.fn.expand("%:p:h")
    extra.test_gofile = get_test_gofile(vim.fn.expand("%"))
    return extra
end

local new_gotests_args = function(parallel)
    local test_template = options.tools.gotests.test_template or ""
    local test_template_dir = options.tools.gotests.test_template_dir or ""
    local args = {}
    if parallel then
        table.insert(args, "-parallel")
    end
    if string.len(test_template) > 0 then
        table.insert(args, "-template")
        table.insert(args, test_template)
        if string.len(test_template_dir) > 0 then
            table.insert(args, "-template_dir")
            table.insert(args, test_template_dir)
        end
    end
    return args
end

local add_test = function(args, extra)
    local gofile = vim.fn.expand("%")
    table.insert(args, "-w")
    table.insert(args, gofile)
    run(args, extra)
end

local show = function(spec)
    local items = {}
    for name, _ in pairs(spec) do
        table.insert(items, name)
    end

    local on_choice = function(choice)
        local callback = spec[choice]
        local ok, _ = pcall(callback)
        if not ok then
            vim.notify("Failed to run selected function", vim.log.levels.ERROR)
        end
    end

    vim.ui.select(items, { prompt = 'Select An Action' }, on_choice)
end

M.fun_test = function(parallel)
    local ns = ts_utils.get_func_method_node_at_pos(unpack(vim.api.nvim_win_get_cursor(0)))
    if ns == nil or ns.name == nil then
        vim.notify("cursor on func/method and execute the command again", vim.log.levels.WARN)
        return
    end

    local funame = ns.name
    local funame_regx = "^" .. ns.name .. "$"
    local args = new_gotests_args(parallel)
    table.insert(args, "-only")
    table.insert(args, funame_regx)

    local extra = new_gotests_extra()
    if type(funame) == "string" and #funame ~= 0 then
        if string.match(string.sub(funame, 1, 1), "%u") then
            extra["test_funame"] = "Test" .. funame
        else
            extra["test_funame"] = "Test_" .. funame
        end
    end

    add_test(args, extra)
end

M.all_test = function(parallel)
    local args = new_gotests_args(parallel)
    local extra = new_gotests_extra()

    table.insert(args, "-all")
    add_test(args, extra)
end

M.exported_test = function(parallel)
    local args = new_gotests_args(parallel)
    local extra = new_gotests_extra()

    table.insert(args, "-exported")
    add_test(args, extra)
end

M.generate = function()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    generate(row, col)
end

local generate = function(row, col)
    local spec = {
        ["Generate exported test"] = M.exported_test,
        ["Generate all test"] = M.all_test,
    }

    local generate_func_test = true
    local ns = ts_utils.get_func_method_node_at_pos(row, col)
    if ns == nil or ns.name == nil then
        generate_func_test = false
    end

    if generate_func_test then
        spec["Generate func/method test"] = M.fun_test
    end

    show(spec)
end

local spec_factory = function(params)
    return function()
        local row, col = params.row, params.col
        generate(row, col)
    end

end

M.generate_actions = function(params)
    local actions = {
        ["Generate test"] = spec_factory(params)
    }

    return actions
end

return M
