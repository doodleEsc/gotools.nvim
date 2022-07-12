local helpers = require("null-ls.helpers")
local methods = require("null-ls.methods")

local CODE_ACTION = methods.internal.CODE_ACTION

return helpers.generator_factory({
  command = function()
      print("code action runs!great!")
  end,
})
