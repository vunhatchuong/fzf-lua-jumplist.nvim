# fzf-lua-jumplist.nvim

An [fzf-lua](https://github.com/ibhagwan/fzf-lua/) extension that offers useful filters for the jump list.

fzf-lua version of [telescope-jumps.nvim](https://github.com/amiroslaw/telescope-jumps.nvim).

The `jumplist` only shows result of current buffer.

# Installation

### lazy.nvim

```lua
{
    "vunhatchuong/fzf-lua-jumplist.nvim",
    dependencies = { "ibhagwan/fzf-lua" },
    keys = {
        {
            "<C-o>",
            function()
                require("fzf-lua-jumplist").jumplist()
            end,
        },
    },
    opts = {},
}
```

# Configuration

These are the default values, you can view it directly in [config.lua](./lua/fzf-lua-jumplist/config.lua).

```lua
{
    ---@type boolean? Whether to jump to the start of the line or maintain the current column in the jump list.
    start_of_line = false,

    ---@type integer? The maximum number of jump results to display.
    max_result = nil,

    ---@type integer? The minimum distance between lines to consider as separate jumps.
    line_distance_threshold = nil,
}

```

# Usage

```lua
require("fzf-lua-jumplist").jumplist()
```

# Known issues

- Current implementation uses map so there's no ordering for the jump list.
