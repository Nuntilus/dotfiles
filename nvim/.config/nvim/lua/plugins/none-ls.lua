return {
	"nvimtools/none-ls.nvim",
	dependencies = {
		"nvimtools/none-ls-extras.nvim",
	},
	config = function()
		local null_ls = require("null-ls")

		-- Ensure Mason-installed binaries (e.g. eslint_d) are on PATH
		vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.prettier,
				null_ls.builtins.formatting.rustfmt,
				require("none-ls.diagnostics.eslint_d"),
				require("none-ls.formatting.eslint_d"),
			},
		})
	end,
}
