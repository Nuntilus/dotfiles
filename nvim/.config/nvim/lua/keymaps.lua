local map = vim.keymap.set -- Alias for easier keymap setting

-- General keymaps
map("n", ",", "@@", { desc = "Repeat last macro" })                     -- Press , to repeat the last macro
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "Save file" })   -- Ctrl + s to save in normal, insert, and visual modes
map("n", "<leader>ww", ":set wrap!<CR>", { desc = "Toggle line wrap" }) -- Toggle line wrapping
-- Makros
map("v", "<leader>-", "c~~pa~~") -- Run macro in register q
map("n", "<leader>a", "ggVG" ) -- Select all text

-- Window navigation with Ctrl + hjkl
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to window below" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to window above" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Lsp keymaps
map("n", "K", require("spell").suggest, { desc = "Hover / Spell suggest" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Show code actions" })
map("n", "rn", vim.lsp.buf.rename, { desc = "Rename symbol" })

-- Debugger
local dap = require("dap")
local dapui = require("dapui")

map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Set break point" })
map("n", "<leader>dc", dap.continue, { desc = "Dap continue" })
map("n", "<leader>dso", dap.step_over, { desc = "Dap step over" })
map("n", "<leader>dsi", dap.step_into, { desc = "Dap step into" })
map("n", "<leader>dsr", dap.step_out, { desc = "Dap step out" })
map("n", "<leader>dr", dap.repl.open, { desc = "Dap open repl" })

-- Filetree
map("n", "<leader>e", ":Neotree filesystem toggle left <cr>", { desc = "Toggle file tree" })

-- Formatter
map("n", "<leader>cf", vim.lsp.buf.format, { desc = "Format document" })

-- Telescope
local telescope = require("telescope.builtin")
map("n", "<leader><leader>", telescope.find_files, { desc = "Find files" })
map("n", "<leader>ff", telescope.find_files, { desc = "Find files" })
map("n", "<leader>fg", telescope.live_grep, { desc = "Live grep" })
map("n", "<leader>fk", telescope.keymaps, { desc = "Search keymaps" })

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

-- Terminal
map("n", "<leader>t", "<cmd>ToggleTerm direction=horizontal size=10<CR>", { desc = "Toggle bottom terminal" })
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
map("t", "<C-l>", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("clear<CR>", true, false, true), "t", false)
end, { desc = "Clear terminal" })

-- =====================================================
-- WHICH-KEY GROUPS (Shows categories when you press <leader>)
-- =====================================================

local wk = require("which-key")

wk.add({
  -- Main category groups
  { "<leader>d", group = " Debug" },
  { "<leader>g", group = " Git" },
  { "<leader>f", group = " Find" },
  { "<leader>c", group = " Code" },
  { "<leader>b", group = " Buffer" },
  { "<leader>h", group = " Harpoon" },
  { "<leader>t", group = " Terminal" },
})

-- Optional: Add a group for Telescope find operations
wk.add({
  { "<leader><leader>", desc = "Find files" },
})
