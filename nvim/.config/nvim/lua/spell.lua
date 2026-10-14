local M = {}

local IGNORE_LABEL = "── Ignore word (add to dictionary) ──"

-- `spellbadword()` (and ]s/[s) return nothing inside treesitter @spell regions
-- on nvim 0.12-dev, so the word under the cursor is checked with vim.spell.check.
local function bad_word_under_cursor()
  local word = vim.fn.expand("<cword>")
  if word == "" then
    return nil
  end

  local bad = vim.spell.check(word)[1]
  if bad and bad[1] == word then
    return word
  end

  return nil
end

function M.suggest()
  if not vim.wo.spell then
    vim.notify("Spell checking is off in this window", vim.log.levels.INFO)
    return
  end

  local word = bad_word_under_cursor()
  if not word then
    vim.notify("No misspelled word here", vim.log.levels.INFO)
    return
  end

  local suggestions = vim.fn.spellsuggest(word, 10)

  -- Always show the ignore option, even if there are no suggestions
  local items = vim.list_extend(vim.deepcopy(suggestions), { IGNORE_LABEL })

  local orig_win = vim.api.nvim_get_current_win()
  local orig_pos = vim.api.nvim_win_get_cursor(orig_win)

  local width = #word + 6
  for _, s in ipairs(items) do
    width = math.max(width, #s + 2)
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, items)
  vim.bo[buf].modifiable = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "cursor",
    row = 1,
    col = 0,
    width = width,
    height = #items,
    style = "minimal",
    border = "rounded",
    title = " " .. word .. " ",
    title_pos = "center",
  })
  vim.wo[win].cursorline = true

  local function apply()
    local idx = vim.api.nvim_win_get_cursor(win)[1]
    local choice = items[idx]
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_set_current_win(orig_win)
    vim.api.nvim_win_set_cursor(orig_win, orig_pos)

    if choice == IGNORE_LABEL then
      -- Add to the spellfile so it persists across restarts
      vim.cmd("spellgood " .. vim.fn.fnameescape(word))
      vim.notify("Added \"" .. word .. "\" to dictionary", vim.log.levels.INFO)
    else
      local keys = vim.api.nvim_replace_termcodes("ciw" .. choice .. "<Esc>", true, false, true)
      vim.api.nvim_feedkeys(keys, "n", false)
    end
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

-- The treesitter highlighter restricts spelling to @spell regions, so matches
-- outside them (code identifiers) are never underlined and must be skipped.
local function in_spell_region(buf, lnum, col)
  if not vim.treesitter.highlighter.active[buf] then
    return true
  end

  local spell = false
  for _, capture in ipairs(vim.treesitter.get_captures_at_pos(buf, lnum - 1, col - 1)) do
    if capture.capture == "spell" then
      spell = true
    elseif capture.capture == "nospell" then
      spell = false
    end
  end

  return spell
end

local function collect(buf)
  local found = {}

  for lnum, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    for _, bad in ipairs(vim.spell.check(line)) do
      local word, kind, col = bad[1], bad[2], bad[3]
      if in_spell_region(buf, lnum, col) then
        table.insert(found, { lnum = lnum, col = col, word = word, kind = kind })
      end
    end
  end

  return found
end

local function jump(direction)
  if not vim.wo.spell then
    vim.notify("Spell checking is off in this window", vim.log.levels.INFO)
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local found = collect(buf)
  if #found == 0 then
    vim.notify("No spelling issues found", vim.log.levels.INFO)
    return
  end

  local cur_lnum, cur_col = unpack(vim.api.nvim_win_get_cursor(0))
  local target, wrapped

  if direction == "next" then
    for _, entry in ipairs(found) do
      if entry.lnum > cur_lnum or (entry.lnum == cur_lnum and entry.col - 1 > cur_col) then
        target = entry
        break
      end
    end
    wrapped = target == nil
    target = target or found[1]
  else
    for i = #found, 1, -1 do
      local entry = found[i]
      if entry.lnum < cur_lnum or (entry.lnum == cur_lnum and entry.col - 1 < cur_col) then
        target = entry
        break
      end
    end
    wrapped = target == nil
    target = target or found[#found]
  end

  vim.api.nvim_win_set_cursor(0, { target.lnum, target.col - 1 })

  if wrapped then
    local edge = direction == "next" and "BOTTOM, continuing at TOP" or "TOP, continuing at BOTTOM"
    vim.notify("search hit " .. edge, vim.log.levels.WARN)
  end
end

function M.next()
  jump("next")
end

function M.prev()
  jump("prev")
end

function M.list()
  if not vim.wo.spell then
    vim.notify("Spell checking is off in this window", vim.log.levels.INFO)
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local items = {}

  for _, entry in ipairs(collect(buf)) do
    table.insert(items, {
      bufnr = buf,
      lnum = entry.lnum,
      col = entry.col,
      end_col = entry.col + #entry.word,
      text = entry.word .. " (" .. entry.kind .. ")",
      type = entry.kind == "bad" and "E" or "W",
    })
  end

  if #items == 0 then
    vim.notify("No spelling issues found", vim.log.levels.INFO)
    return
  end

  vim.fn.setqflist({}, " ", {
    title = "Spelling (" .. #items .. ")",
    items = items,
  })
  vim.cmd("copen")
end

return M
