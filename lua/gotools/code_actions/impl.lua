local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local CODE_ACTION = methods.internal.CODE_ACTION

return h.make_builtin({
    name = "impl",
    meta = {
        url = "https://github.com/josharian/impl",
        description = "impl generates method stubs for implementing an interface.",
    },
    method = CODE_ACTION,
    filetypes = { "go" },
    generator = {
        fn = function(params)
            local impl = require("gotools.core.impl")
            local actions = {}
            for k, v in pairs(impl.generate_actions(params)) do
                table.insert(actions, {
                    title = k,
                    action = v
                })
            end
            return actions
        end,
    },
})
