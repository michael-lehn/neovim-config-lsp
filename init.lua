vim.loader.enable()
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

require('user.options')
require('user.keymaps')
require('user.lazy')
require('user.format')

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'c', 'cpp', 'lua', 'python' },
    callback = function(args)
        vim.schedule(function()
            require('nvim-treesitter')
                .install({ 'c', 'cpp', 'lua', 'python' })
                :wait(300000)
            local ft = vim.bo[args.buf].filetype
            local ft = vim.bo[args.buf].filetype
            local ft2lang = {}
            local lang = ft2lang[ft] or ft
            pcall(vim.treesitter.start, args.buf, lang)
        end)
    end,
})
