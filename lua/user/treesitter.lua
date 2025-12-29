local ok, ts = pcall(require, 'nvim-treesitter.config')
if not ok then
    vim.notify('can not call nvim-treesitter.config')
    return
end

ts.setup({
    ensure_installed = { 'c', 'cpp', 'lua', 'python' },
    highlight = { enable = true },
    indent = { enable = true },
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'python', 'c', 'cpp', 'lua' },
    callback = function()
        vim.treesitter.start()
    end,
})
