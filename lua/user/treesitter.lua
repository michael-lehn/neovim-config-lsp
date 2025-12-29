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
