local export_tools = {}

return setmetatable(export_tools, {
    __index = function(t, k)
        local ok, tool = pcall(require, string.format("gotools.code_actions.%s", k))
        if not ok then
            vim.notify(string.format("failed to load builtin %s ; please check your config", k), vim.log.levels.WARN)
            return
        end

        -- rawset(t, k, tool)
        return tool
    end,
})

-- return setmetatable(export_tools, {
--     __index = function(t, k)
--         if not rawget(t, k) then
--             vim.notify(string.format("failed to load builtin %s ; please check your config", k), vim.log.levels.WARN)
--         end
--
--         return rawget(t, k)
--     end,
-- })
