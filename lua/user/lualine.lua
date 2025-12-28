require("lualine").setup({
	options = {
		disabled_filetypes = {
			statusline = {
				"fugitive",
				"gitcommit",
				"help",
				"NvimTree",
				"neo-tree",
				"TelescopePrompt",
			},
			winbar = { "fugitive" },
		},
	},
})
