vim.api.nvim_create_autocmd('FileType', {
    pattern = 'arduino',
    callback = function()
        vim.bo.tabstop = 8
        vim.bo.shiftwidth = 4
        vim.bo.expandtab = true
    end,
})
