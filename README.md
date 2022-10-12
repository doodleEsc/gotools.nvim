# gotools

`gotools.nvim` provides some code action functions that can be integrated with null-ls or can be used separately

## Install
* Requires Neovim >= 0.7
* gotests
* gomodifytags
Recommend `[mason.nvim](https://github.com/williamboman/mason.nvim)` to manage binary tools

## Setup
```lua

use({
    'doodleEsc/gotools.nvim',
    config = function()
        require("gotools").setup({
            tools = {
                gotests = {
                    bin = "/path/to/gotests", -- gotests binary path
                    test_template = nil,
                    test_template_dir = nil,
                },
                gomodifytags = {
                    bin = "/path/to/gomodifytags", -- gomodifytags binary path
                }
            }
        })
    end
})
```


## Snapshots

### gotests
![](https://cdn.jsdelivr.net/gh/doodleEsc/blog-images/gotests.gif)

### gomodifytags
![](https://cdn.jsdelivr.net/gh/doodleEsc/blog-images/gomodifytags.gif)

## Usage

### With Null-ls
```lua
local null_ls = require("null-ls")

null_ls.setup({
    cmd = { "nvim" },
    sources = {
        require("gotools").code_actions.gotests,
        require("gotools").code_actions.gomodifytags,
    },
})
```

### Independent

#### gotests
```lua
lua require("gotools.core.gotests").generate()
```

#### gomodifytags
```lua
lua require("gotools.core.gomodifytags").add_tags()
lua require("gotools.core.gomodifytags").remove_tags()
```
