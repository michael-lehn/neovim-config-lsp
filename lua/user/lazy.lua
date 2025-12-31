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
    rocks = { enabled = false },

    spec = {
        -- ------------------------------------------------------------
        -- Core deps
        -- ------------------------------------------------------------
        { 'nvim-lua/plenary.nvim', lazy = true },
        { 'nvim-lua/popup.nvim', lazy = true },

        -- ------------------------------------------------------------
        -- Colorscheme
        -- ------------------------------------------------------------
        {
            'michael-lehn/darkplus.nvim',
            lazy = false,
            priority = 1000,
            config = function()
                require('user.colorscheme')
            end,
        },

        { 'oxidescheme/oxide.nvim', lazy = true },
        { 'Ferouk/bearded-nvim', lazy = true },
        { 'joshdick/onedark.vim', lazy = true },
        { 'sainnhe/everforest', lazy = true },

        -- ------------------------------------------------------------
        -- UI
        -- ------------------------------------------------------------
        { 'nvim-tree/nvim-web-devicons', lazy = true },

        {
            'nvim-lualine/lualine.nvim',
            event = 'VeryLazy',
            dependencies = { 'nvim-tree/nvim-web-devicons' },
            config = function()
                require('user.lualine')
            end,
        },

        {
            'folke/which-key.nvim',
            event = 'VeryLazy',
            opts = { delay = 700 },
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
            'nvim-tree/nvim-tree.lua',
            cmd = {
                'NvimTreeToggle',
                'NvimTreeOpen',
                'NvimTreeFocus',
                'NvimTreeFindFile',
            },
            keys = {
                {
                    '<C-e>',
                    function()
                        require('nvim-tree.api').tree.find_file({
                            open = true,
                            focus = true,
                        })
                    end,
                    desc = 'NvimTree: Reveal current file',
                },
            },
            dependencies = { 'nvim-tree/nvim-web-devicons' },
            config = function()
                require('user.nvim-tree')
            end,
        },

        {
            'nanozuki/tabby.nvim',
            event = 'VeryLazy',
            dependencies = { 'nvim-tree/nvim-web-devicons' },
            opts = {
                line = function(line)
                    local theme = {
                        fill = 'TabLineFill',
                        head = 'TabLine',
                        current_tab = 'TabLineSel',
                        tab = 'TabLine',
                    }

                    return {
                        { '  Tabs ', hl = theme.head },
                        line.sep('', theme.head, theme.fill),

                        line.tabs().foreach(function(tab)
                            local hl = tab.is_current() and theme.current_tab
                                or theme.tab

                            local wins = tab.wins().foreach(function(win, i)
                                local buf = win.buf().id
                                local ft = vim.bo[buf].filetype
                                if ft == 'NvimTree' then
                                    return ''
                                end
                                return {
                                    (i == 1) and ' ' or ' | ',
                                    win.buf_name(),
                                }
                            end)

                            return {
                                line.sep('', hl, theme.fill),
                                ' ',
                                tab.number(),
                                ':',
                                wins,
                                ' ',
                                line.sep('', hl, theme.fill),
                                hl = hl,
                            }
                        end),

                        hl = theme.fill,
                    }
                end,

                option = {
                    buf_name = { mode = 'tail' },
                },
            },
        },

        {
            'nvim-lua/plenary.nvim',
            event = 'VeryLazy',
            config = function()
                pcall(require, 'user.tabby')
            end,
        },

        -- ------------------------------------------------------------
        -- Telescope / Harpoon
        -- ------------------------------------------------------------
        {
            'nvim-telescope/telescope.nvim',
            tag = 'v0.2.0',
            cmd = 'Telescope',
            dependencies = { 'nvim-lua/plenary.nvim' },
            config = function()
                require('user.telescope')
            end,
        },

        {
            'ThePrimeagen/harpoon',
            branch = 'harpoon2',
            dependencies = { 'nvim-lua/plenary.nvim' },
            keys = {
                { '<leader>ha', desc = 'Harpoon: Add file' },
                { '<leader>H', desc = 'Harpoon: Quick menu' },
                { '<leader>h1', desc = 'Harpoon: Go to 1' },
                { '<leader>h2', desc = 'Harpoon: Go to 2' },
                { '<leader>h3', desc = 'Harpoon: Go to 3' },
                { '<leader>h4', desc = 'Harpoon: Go to 4' },
            },
            config = function()
                require('user.harpoon')
            end,
        },

        -- ------------------------------------------------------------
        -- Autopairs
        -- ------------------------------------------------------------
        {
            'windwp/nvim-autopairs',
            event = 'InsertEnter',
            config = function()
                require('nvim-autopairs').setup({})
            end,
        },

        -- ------------------------------------------------------------
        -- CMP
        -- ------------------------------------------------------------
        {
            'hrsh7th/nvim-cmp',
            event = 'InsertEnter',
            dependencies = {
                { 'hrsh7th/cmp-buffer', event = 'InsertEnter' },
                { 'hrsh7th/cmp-path', event = 'InsertEnter' },
                { 'hrsh7th/cmp-cmdline' },
                { 'hrsh7th/cmp-nvim-lsp' },
                { 'hrsh7th/cmp-nvim-lua' },
            },
            config = function()
                require('user.cmp')
            end,
        },

        -- ------------------------------------------------------------
        -- LSP (native) + LSPSaga + Mason
        -- ------------------------------------------------------------
        {
            'nvimdev/lspsaga.nvim',
            event = { 'BufReadPre', 'BufNewFile' },
            config = function() end,
        },

        {
            'mason-org/mason.nvim',
            event = 'VeryLazy',
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
                require('user.lsp.mason').bootstrap()
            end,
        },

        { 'nvimtools/none-ls.nvim', event = 'VeryLazy' },

        {
            'neovim/nvim-lspconfig',
            event = 'VeryLazy',
            dependencies = {
                'nvimdev/lspsaga.nvim',
            },
            config = function()
                require('user.lsp')
            end,
        },
    },

    defaults = { lazy = true },
    install = { colorscheme = { 'darkplus' } },
})
