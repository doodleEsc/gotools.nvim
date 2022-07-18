local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local CODE_ACTION = methods.internal.CODE_ACTION

return h.make_builtin({
    name = "gomodifytags",
    meta = {
        url = "https://github.com/fatih/gomodifytags",
        description = "Go tool to modify struct field tags",
    },
    method = CODE_ACTION,
    filetypes = { "go" },
    generator = {
        fn = function(params)

            local gomodifytags = require("gotools.core.gomodifytags")
            local actions = {}
            for k, v in pairs(gomodifytags.generate_actions(params)) do
                table.insert(actions, {
                    title = k,
                    action = v
                })
            end
            return actions
        end,
    },
})
