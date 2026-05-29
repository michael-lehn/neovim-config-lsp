vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    pattern = { '*.abc', '*.hdr' },
    callback = function()
        vim.bo.filetype = 'abc'
    end,
})
