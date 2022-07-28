# gotools


gotools.nvim provides some code action functions that can be integrated with null-ls or can be used separately

## Install
* Requires Neovim >= 0.7
* 

```lua
```

Via github web page:

Click on `Use this template`

![](https://docs.github.com/assets/cb-36544/images/help/repository/use-this-template-button.png)

## Features and structure

- 100% Lua
- Github actions to run tests and check for formatting errors (Stylua)
- Tests created with [busted](https://olivinelabs.com/busted/) + [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

### Plugin structure

```
.
├── lua
│   ├── plugin_name
│   │   └── module.lua
│   └── plugin_name.lua
├── Makefile
├── plugin
│   └── plugin_name.lua
├── README.md
├── tests
│   ├── minimal_init.lua
│   └── plugin_name
│       └── plugin_name_spec.lua
```
