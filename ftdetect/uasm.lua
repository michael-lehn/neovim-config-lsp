vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.s",
	callback = function()
		vim.bo.filetype = "uasm"
	end,
})
