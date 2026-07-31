local M = {}

local defaults = {
  see_docs = "K",
  close = { "q", "<Esc>" },
  command = "haredoc",
}

local config = vim.deepcopy(defaults)

local function as_list(value)
  return type(value) == "table" and value or { value }
end

local function identifier_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]

  local left = line:sub(1, col + 1):match("[%w_:]+$") or ""
  local right = line:sub(col + 2):match("^[%w_:]+") or ""
  local symbol = left .. right

  if symbol == "" then
    return
  end

  for _, part in ipairs(vim.split(symbol, "::", { plain = true })) do
    if not part:match("^[%a_][%w_]*$") then
      return
    end
  end

  return symbol
end

function M.show()
  local symbol = identifier_under_cursor()

  if not symbol then
    vim.notify("No Hare identifier under cursor", vim.log.levels.WARN)
    return
  end

  if vim.fn.executable(config.command) ~= 1 then
    vim.notify(
      "Executable not found: " .. config.command .. "; install haredoc or set opts.command",
      vim.log.levels.ERROR
    )
    return
  end

  local width = math.max(1, math.min(90, vim.o.columns - 4))
  local height = math.max(1, math.min(14, vim.o.lines - 4))
  local buf = vim.api.nvim_create_buf(false, true)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " haredoc: " .. symbol .. " ",
    title_pos = "center",
  })

  vim.bo[buf].bufhidden = "wipe"

  local job = vim.fn.jobstart({ config.command, symbol }, {
    term = true,
  })

  if job <= 0 then
    vim.api.nvim_win_close(win, true)
    vim.notify(
      "Failed to start " .. config.command .. "; is haredoc installed?",
      vim.log.levels.ERROR
    )
    return
  end

  vim.cmd.stopinsert()

  if config.close ~= false then
    for _, key in ipairs(as_list(config.close)) do
      vim.keymap.set("n", key, function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
      end, {
        buffer = buf,
        nowait = true,
        desc = "Close haredoc",
      })
    end
  end
end

function M.setup(opts)
  config = vim.tbl_extend(
    "force",
    vim.deepcopy(defaults),
    opts or {}
  )

  local group = vim.api.nvim_create_augroup("Haredoc", {
    clear = true,
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "hare",

    callback = function(event)
      if config.see_docs == false then
        return
      end

      vim.keymap.set("n", config.see_docs, M.show, {
        buffer = event.buf,
        desc = "Show haredoc",
      })
    end,
  })
end

return M
