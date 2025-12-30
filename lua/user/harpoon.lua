local ok, harpoon = pcall(require, 'harpoon')
if not ok then
    return
end

local list = harpoon:list()

vim.keymap.set('n', '<leader>H', function()
    harpoon.ui:toggle_quick_menu(list)
end, { desc = 'Harpoon: Menu' })

vim.keymap.set('n', '<leader>ha', function()
    list:add()
end, { desc = 'Harpoon: Add file' })

vim.keymap.set('n', '<leader>h1', function()
    list:select(1)
end, { desc = 'Harpoon: File 1' })
vim.keymap.set('n', '<leader>h2', function()
    list:select(2)
end, { desc = 'Harpoon: File 2' })
vim.keymap.set('n', '<leader>h3', function()
    list:select(3)
end, { desc = 'Harpoon: File 3' })
vim.keymap.set('n', '<leader>h4', function()
    list:select(4)
end, { desc = 'Harpoon: File 4' })
