local lspsaga_status_ok, lspsaga = pcall(require, 'lspsaga')
if not lspsaga_status_ok then
    vim.notify("can not call 'lspsaga'")
    return
end

lspsaga.setup({
    ui = { border = 'rounded' },
    lightbulb = { enable = false },
    symbol_in_winbar = { enable = false },
})

vim.keymap.set(
    'n',
    '<leader>a',
    '<cmd>Lspsaga code_action<CR>',
    { desc = 'LSP Code Actions' }
)
vim.keymap.set(
    'n',
    '<leader>r',
    '<cmd>Lspsaga rename<CR>',
    { desc = 'LSP Rename' }
)
vim.keymap.set(
    'n',
    '<leader>d',
    '<cmd>Lspsaga show_line_diagnostics<CR>',
    { desc = 'Line Diagnostics' }
)
