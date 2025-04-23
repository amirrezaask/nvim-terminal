# Nvim-Terminal
Simple terminal helper for neovim.

## Installation
Install with your favorite package manager.


## Usage

```lua
vim.keymap.set({ "n", "t" }, "YOUR KEY BINDING", require("nvim-terminal").toggle_bottom({cmd=<optional command>})) -- This will toggle a terminal
vim.keymap.set({ "n", "t" }, "YOUR KEY BINDING", require("nvim-terminal").toggle_floating({cmd=<optional command>})) -- This will toggle a terminal
vim.keymap.set({ "n", "t" }, "YOUR KEY BINDING", require("nvim-terminal").toggle_tab({cmd=<optional command>})) -- This will toggle a terminal
vim.keymap.set({ "n", "t" }, "YOUR KEY BINDING", require("nvim-terminal").toggle_buffer({cmd=<optional command>})) -- This will toggle a terminal
vim.keymap.set({ "n", "t" }, "YOUR KEY BINDING", require("nvim-terminal").toggle_right({cmd=<optional command>})) -- This will toggle a terminal
```
