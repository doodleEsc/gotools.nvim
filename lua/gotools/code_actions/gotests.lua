local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local CODE_ACTION = methods.internal.CODE_ACTION

return h.make_builtin({
    name = "gotests",
    meta = {
        url = "https://github.com/cweill/gotests",
        description = "Automatically generate Go test boilerplate from your source code.",
    },
    method = CODE_ACTION,
    filetypes = { "go" },
    generator = {
        fn = function(params)
            local gotests = require("gotools.core.gotests")

            local actions = {}
            for k, v in pairs(gotests.actions) do
                table.insert(actions, {
                    title = k,
                    action = v
                })
            end
            return actions
        end,
    },
})
