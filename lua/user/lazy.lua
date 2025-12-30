local fn = vim.fn
local lazypath = fn.stdpath('data') .. '/lazy/lazy.nvim'

if not (vim.uv or vim.loop).fs_stat(lazypath) then
    fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable',
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    rocks = {
        enabled = false,
    },
    spec = {
        -- Core deps
        { 'nvim-lua/plenary.nvim' },
        { 'nvim-lua/popup.nvim' },

        -- UI
        { 'nvim-tree/nvim-web-devicons' },
        { 'nvim-lualine/lualine.nvim' },
        { 'nvim-tree/nvim-tree.lua' },
        {
            'folke/which-key.nvim',
            event = 'VeryLazy',
            opts = {
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            },
            keys = {
                {
                    '<leader>?',
                    function()
                        require('which-key').show({ global = false })
                    end,
                    desc = 'Buffer Local Keymaps (which-key)',
                },
            },
        },
        {
            'nvim-telescope/telescope.nvim',
            tag = 'v0.2.0',
            dependencies = { 'nvim-lua/plenary.nvim' },
        },
        -- Treesitter
        {
            'nvim-treesitter/nvim-treesitter',
            lazy = false,
            build = ':TSUpdate',
        },

        -- Autopairs
        {
            'windwp/nvim-autopairs',
            event = 'InsertEnter',
            config = function()
                require('nvim-autopairs').setup({})
            end,
        },

        -- Colorschemes
        { 'oxidescheme/oxide.nvim' },
        { 'Ferouk/bearded-nvim' },
        { 'joshdick/onedark.vim' },
        { 'sainnhe/everforest' },
        { 'michael-lehn/darkplus.nvim' },
        { 'HiPhish/rainbow-delimiters.nvim' },

        -- CMP
        { 'hrsh7th/nvim-cmp', event = 'InsertEnter' },
        { 'hrsh7th/cmp-buffer', event = 'InsertEnter' },
        { 'hrsh7th/cmp-path', event = 'InsertEnter' },
        { 'hrsh7th/cmp-cmdline' },
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'hrsh7th/cmp-nvim-lua' },

        -- LSP tooling
        {
            'mason-org/mason.nvim',
            lazy = false,
            opts = {
                max_concurrent_installers = 14,
                ui = {
                    icons = {
                        package_installed = '✓',
                        package_pending = '➜',
                        package_uninstalled = '✗',
                    },
                },
            },
            config = function(_, opts)
                require('mason').setup(opts)
                require('user.lsp.mason') -- hier drin machen wir den Bootstrap
            end,
        },
        { 'nvimtools/none-ls.nvim' },
        { 'nvimdev/lspsaga.nvim' },
    },

    defaults = { lazy = false },
})
