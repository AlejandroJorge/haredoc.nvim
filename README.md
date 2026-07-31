# haredoc.nvim

A small Neovim plugin for viewing documentation for Hare identifiers under the cursor.

## Usage

The default keymap is `K` in Hare buffers.

### Configuration

The two keymap options can be customized when calling `setup`:

```lua
require("haredoc").setup({
  -- Keymap for showing documentation in Hare buffers (default: "K").
  -- Set to false to disable it.
  see_docs = "<leader>h",

  -- Keymap(s) for closing the documentation window
  -- (default: { "q", "<Esc>" }).
  close = { "q", "<Esc>" },
})
```

Both `see_docs` and `close` accept a single keymap as a string. `close` also
accepts a list of keymaps, and can be set to `false` to disable the close
mapping.

### vim.pack

```lua
vim.pack.add({
  "https://github.com/AlejandroJorge/haredoc.nvim",
})

require("haredoc").setup()
```

### lazy.nvim

```lua
{
  "AlejandroJorge/haredoc.nvim",
  config = function()
    require("haredoc").setup()
  end,
}
```
