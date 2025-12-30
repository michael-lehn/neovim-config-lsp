vim.keymap.set('n', '<leader>ta', ':$tabnew<CR>', { desc = 'Tab: New' })
vim.keymap.set('n', '<leader>tc', ':tabclose<CR>', { desc = 'Tab: Close' })
vim.keymap.set('n', '<leader>to', ':tabonly<CR>', { desc = 'Tab: Only' })
vim.keymap.set('n', '<leader>tn', ':tabnext<CR>', { desc = 'Tab: Next' })
vim.keymap.set(
    'n',
    '<leader>tp',
    ':tabprevious<CR>',
    { desc = 'Tab: Previous' }
)
vim.keymap.set('n', '<leader>tmp', ':-tabmove<CR>', { desc = 'Tab: Move left' })
vim.keymap.set(
    'n',
    '<leader>tmn',
    ':+tabmove<CR>',
    { desc = 'Tab: Move right' }
)

for i = 1, 9 do
    vim.keymap.set('n', '<leader>t' .. i, i .. 'gt', {
        desc = 'Tab: Go to ' .. i,
    })
end
