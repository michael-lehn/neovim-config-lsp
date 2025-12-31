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

vim.g.rainbow_delimiters = {
    strategy = {
        [''] = require('rainbow-delimiters').strategy['global'],
    },
    query = {
        [''] = 'rainbow-delimiters',
    },
    highlight = {
        'TSRainbowRed',
        'TSRainbowYellow',
        'TSRainbowOrange',
        'TSRainbowCoral',
        'TSRainbowViolet',
        'TSRainbowBlue',
        'TSRainbowPink',
        'TSRainbowGreen',
    },
}

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'c', 'cpp', 'lua', 'python' },
    callback = function(ev)
        vim.schedule(function()
            pcall(vim.treesitter.start, ev.buf) -- start nach dem ersten Render-Tick
        end)
    end,
})
