local M = {}

function M.suggest()
  local word = vim.fn.spellbadword()[1]
  if not vim.wo.spell or word == "" then
    vim.lsp.buf.hover()
    return
  end

  local suggestions = vim.fn.spellsuggest(word, 10)
  if #suggestions == 0 then
    vim.notify("No suggestions for: " .. word, vim.log.levels.INFO)
    return
  end

  local orig_win = vim.api.nvim_get_current_win()
  local orig_pos = vim.api.nvim_win_get_cursor(orig_win)

  local width = #word + 6
  for _, s in ipairs(suggestions) do
    width = math.max(width, #s + 2)
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, suggestions)
  vim.bo[buf].modifiable = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "cursor",
    row = 1,
    col = 0,
    width = width,
    height = #suggestions,
    style = "minimal",
    border = "rounded",
    title = " " .. word .. " ",
    title_pos = "center",
  })
  vim.wo[win].cursorline = true

  local function apply()
    local idx = vim.api.nvim_win_get_cursor(win)[1]
    local choice = suggestions[idx]
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_set_current_win(orig_win)
    vim.api.nvim_win_set_cursor(orig_win, orig_pos)
    local keys = vim.api.nvim_replace_termcodes("ciw" .. choice .. "<Esc>", true, false, true)
    vim.api.nvim_feedkeys(keys, "n", false)
  end

  local function close()
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_set_current_win(orig_win)
  end

  local opts = { buffer = buf, nowait = true, silent = true }
  vim.keymap.set("n", "<CR>", apply, opts)
  vim.keymap.set("n", "<Esc>", close, opts)
  vim.keymap.set("n", "q", close, opts)
end

return M
