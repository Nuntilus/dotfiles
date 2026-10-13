return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	config = function()
		local ts = require("nvim-treesitter")

		ts.setup()

		ts.install({ "lua", "rust", "typescript", "go" })

		-- The main branch has no `highlight`/`indent`/`auto_install` options:
		-- highlighting and indenting must be started per buffer, and missing
		-- parsers must be installed by hand.
		local function start(buf, lang)
			if not vim.api.nvim_buf_is_valid(buf) then
				return
			end
			if pcall(vim.treesitter.start, buf, lang) then
				vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end
		end

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
			callback = function(args)
				local lang = vim.treesitter.language.get_lang(args.match)
				if not lang then
					return
				end

				if vim.list_contains(ts.get_installed("parsers"), lang) then
					start(args.buf, lang)
				elseif vim.list_contains(ts.get_available(), lang) then
					ts.install(lang):await(function()
						vim.schedule(function()
							start(args.buf, lang)
						end)
					end)
				else
					start(args.buf, lang)
				end
			end,
		})

		-- nvim-treesitter-textobjects (main branch): no auto keymaps table,
		-- must wire up keymaps manually. See keymaps.lua for the actual binds.
		require("nvim-treesitter-textobjects").setup({
			select = {
				lookahead = true,
			},
			move = {
				set_jumps = true,
			},
		})
	end,
}
