local map = vim.keymap.set -- Alias for easier keymap setting

-- General keymaps
map("n", ",", "@@", { desc = "Repeat last macro" })                     -- Press , to repeat the last macro
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "Save file" })   -- Ctrl + s to save in normal, insert, and visual modes
map("n", "<leader>ww", ":set wrap!<CR>", { desc = "Toggle line wrap" }) -- Toggle line wrapping
map({"v", "n"}, "<leader>p", "\"_dP", { desc = "Paste without overwriting register" }) -- Paste in visual mode without overwriting the default register

-- Makros
map("v", "<leader>-", "c~~pa~~", {desc = "Put a line trhu text in markdown"})
map("n", "<leader>a", "ggVG" , {desc = "Select all"}) -- Select all text

-- Quckfix list navigation
map("n", "<M-j>", "<cmd>cnext<CR>", { desc = "Next quickfix item" })
map("n", "<M-k>", "<cmd>cprev<CR>", { desc = "Previous quickfix item" })

-- Window navigation is handled by vim-tmux-navigator on <C-h/j/k/l>

-- Lsp keymaps
map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Show code actions" })
map("n", "rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
-- diagnostics
map("n", "<leader>dn", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
map("n", "<leader>dm", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Previous diagnostic" })
map("n", "<leader>dl", function()
  vim.diagnostic.setloclist()
end, { desc = "List diagnostics in file" })

-- Spelling (z-family)
map("n", "z=", require("spell").suggest, { desc = "Spell suggest (floating)" })
map("n", "zn", "]s", { desc = "Next misspelled word" })
map("n", "zb", "[s", { desc = "Previous misspelled word" })

-- Filetree
map("n", "<leader>e", ":Neotree filesystem toggle left <cr>", { desc = "Toggle file tree" })

-- Debugger (nvim-dap / nvim-dap-ui)
local dap = require("dap")
local dapui = require("dapui")

map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
map("n", "<leader>dB", function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Conditional Breakpoint" })
map("n", "<leader>dc", dap.continue, { desc = "Continue / Start" })
map("n", "<leader>di", dap.step_into, { desc = "Step Into" })
map("n", "<leader>do", dap.step_over, { desc = "Step Over" })
map("n", "<leader>dO", dap.step_out, { desc = "Step Out" })
map("n", "<leader>dr", dap.repl.toggle, { desc = "Toggle REPL" })
map("n", "<leader>dq", dap.terminate, { desc = "Terminate" })
map("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })

-- Formatter
map("n", "<leader>cf", vim.lsp.buf.format, { desc = "Format document" })

-- Telescope
local telescope = require("telescope.builtin")
map("n", "<leader><leader>", telescope.find_files, { desc = "Find files" })
map("n", "<leader>ff", telescope.find_files, { desc = "Find files" })
map("n", "<leader>fa", function()
  telescope.find_files({ hidden = true, no_ignore = true })
end, { desc = "Find all files (hidden + gitignored)" })
map("n", "<leader>fg", telescope.live_grep, { desc = "Live grep" })
map("n", "<leader>fk", telescope.keymaps, { desc = "Search keymaps" })
map("n", "<leader>fb", telescope.buffers, { desc = "Search buffers" })

-- Lazygit
map("n", "<leader>gg", ":LazyGit <CR>", { desc = "Lazygit" })

-- Buffers
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close Buffer" })
map("n", "<leader>bD", "<cmd>%bdelete<CR>", { desc = "Close All Buffers" })
map("n", "<leader>bo", "<cmd>%bdelete|e#<CR>", { desc = "Close Other Buffers" })
map("n", "<leader>be", "<cmd>ene<CR>", { desc = "New Empty Buffer" })
map("n", "<leader>bx", "<cmd>bdelete!<CR>", { desc = "Force Close Buffer" })
map("n", "<leader>bl", "<cmd>ls<CR>", { desc = "List Buffers" })
map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next Buffer" })
map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next Buffer" })
map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous Buffer" })
map("n", "<S-tab>", "<cmd>bprevious<CR>", { desc = "Previous Buffer" })

-- =====================================================
-- WHICH-KEY GROUPS (Shows categories when you press <leader>)
-- =====================================================

local wk = require("which-key")

wk.add({
  -- Main category groups
  { "<leader>d", group = " Debug / Diagnostics" },
  { "<leader>g", group = " Git" },
  { "<leader>f", group = " Find" },
  { "<leader>c", group = " Code" },
  { "<leader>b", group = " Buffer" },
})

-- Optional: Add a group for Telescope find operations
wk.add({
  { "<leader><leader>", desc = "Find files" },
})

-- =====================================================
-- TREESITTER TEXTOBJECTS (nvim-treesitter-textobjects, main branch)
-- On the "main" branch there is no automatic keymaps table, so we call
-- the select/move/swap modules directly. Setup (lookahead, set_jumps)
-- lives in plugins/treesiter.lua.
-- =====================================================

-- Select textobjects: use with operators, e.g. daf, vic, yia
local ts_select = function(textobj)
  return function()
    require("nvim-treesitter-textobjects.select").select_textobject(textobj, "textobjects")
  end
end

map({ "x", "o" }, "af", ts_select("@function.outer"), { desc = "Around function (textobj)" })
map({ "x", "o" }, "if", ts_select("@function.inner"), { desc = "Inside function (textobj)" })
map({ "x", "o" }, "ac", ts_select("@class.outer"), { desc = "Around class (textobj)" })
map({ "x", "o" }, "ic", ts_select("@class.inner"), { desc = "Inside class (textobj)" })
map({ "x", "o" }, "aa", ts_select("@parameter.outer"), { desc = "Around parameter (textobj)" })
map({ "x", "o" }, "ia", ts_select("@parameter.inner"), { desc = "Inside parameter (textobj)" })

-- Move between textobjects
local ts_move = function(direction, textobj)
  return function()
    require("nvim-treesitter-textobjects.move")[direction](textobj, "textobjects")
  end
end

map({ "n", "x", "o" }, "]f", ts_move("goto_next_start", "@function.outer"), { desc = "Next function start" })
map({ "n", "x", "o" }, "]F", ts_move("goto_next_end", "@function.outer"), { desc = "Next function end" })
map({ "n", "x", "o" }, "]a", ts_move("goto_next_start", "@parameter.inner"), { desc = "Next parameter" })
map({ "n", "x", "o" }, "[f", ts_move("goto_previous_start", "@function.outer"), { desc = "Previous function start" })
map({ "n", "x", "o" }, "[F", ts_move("goto_previous_end", "@function.outer"), { desc = "Previous function end" })
map({ "n", "x", "o" }, "[a", ts_move("goto_previous_start", "@parameter.inner"), { desc = "Previous parameter" })

-- Swap parameter with next/previous
map("n", "<leader>na", function()
  require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
end, { desc = "Swap parameter with next" })
map("n", "<leader>pa", function()
  require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner")
end, { desc = "Swap parameter with previous" })
