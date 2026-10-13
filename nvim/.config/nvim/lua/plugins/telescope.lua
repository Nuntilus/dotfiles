return {
    {
        'nvim-telescope/telescope.nvim', version = '*',
        dependencies = {
          'nvim-lua/plenary.nvim',
          { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
          'nvim-telescope/telescope-ui-select.nvim',
      },
      config = function()
        local telescope = require("telescope")

        telescope.setup {
          -- defaults = {
          --   vimgrep_arguments = {
          --     "rg",
          --     "--color=never",
          --     "--no-heading",
          --     "--with-filename",
          --     "--line-number",
          --     "--column",
          --     "--smart-case",
          --     "--hidden",
          --     "--no-ignore",
          --   },
          --   file_ignore_patterns = { "%.git/" },
          -- },
          extensions = {
            fzf = {},
            ["ui-select"] = {
              require("telescope.themes").get_dropdown {
                -- even more opts
              }

            }
          }
        }

        telescope.load_extension("fzf")
        telescope.load_extension("ui-select")
      end
    }
  }
