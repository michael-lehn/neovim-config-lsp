require('nvim-treesitter').setup({
    install_dir = vim.fn.stdpath('data') .. '/site',
})

require('nvim-treesitter')
    .install({
        'c',
        'cpp',
        'lua',
        'python',
    })
    :wait(300000)

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'c', 'cpp', 'lua', 'python' },
    callback = function()
        vim.treesitter.start()
    end,
})
