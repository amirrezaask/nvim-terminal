# Nvim-Terminal
Simple terminal helper for neovim.

## Installation
Install with your favorite package manager.


## Usage

```lua
vim.keymap.set({ "n", "t" }, "YOUR KEY BINDING", require("nvim-terminal")("bottom")) -- This will toggle a terminal
vim.keymap.set({ "n", "t" }, "YOUR KEY BINDING", require("nvim-terminal")("float")) -- This will toggle a terminal
vim.keymap.set({ "n", "t" }, "YOUR KEY BINDING", require("nvim-terminal")("tab")) -- This will toggle a terminal
```
