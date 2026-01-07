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
        {
            'nvim-lua/plenary.nvim',
            event = 'VeryLazy',
            config = function()
                pcall(require, 'user.tabby')
            end,
        },
        {
            'nvim-lua/popup.nvim',
            lazy = true,
        },
        {
            'nvim-treesitter/nvim-treesitter',
            lazy = false,
            build = ':TSUpdate',
        },
        {
            'HiPhish/rainbow-delimiters.nvim',
            event = 'BufReadPost',
            config = function()
                require('rainbow-delimiters.setup').setup({
                    strategy = {
                        [''] = 'rainbow-delimiters.strategy.global',
                    },
                    query = {
                        [''] = 'rainbow-delimiters',
                    },
                    highlight = {
                        'RainbowDelimiterRed',
                        'RainbowDelimiterYellow',
                        'RainbowDelimiterBlue',
                        'RainbowDelimiterOrange',
                        'RainbowDelimiterGreen',
                        'RainbowDelimiterViolet',
                        'RainbowDelimiterCyan',
                    },
                })
            end,
        },
        {
            'Julian/lean.nvim',
            event = { 'BufReadPre *.lean', 'BufNewFile *.lean' },

            dependencies = {
                'nvim-lua/plenary.nvim',

                -- optional dependencies:

                -- a completion engine
                --    hrsh7th/nvim-cmp or Saghen/blink.cmp are popular choices

                -- 'nvim-telescope/telescope.nvim', -- for 2 Lean-specific pickers
                -- 'andymass/vim-matchup',          -- for enhanced % motion behavior
                -- 'andrewradev/switch.vim',        -- for switch support
                -- 'tomtom/tcomment_vim',           -- for commenting
            },

            opts = { -- see below for full configuration options
                mappings = true,
            },
        },
        {
            'lervag/vimtex',
            event = { 'BufReadPre *.tex', 'BufNewFile *.tex' },
            ft = { 'tex' },
            init = function()
                vim.g.vimtex_quickfix_mode = 2
                vim.g.vimtex_quickfix_open_on_warning = 0
                vim.g.tex_flavor = 'latex'

                vim.g.vimtex_compiler_method = 'latexmk'
                vim.g.vimtex_compiler_latexmk_engines = {
                    _ = '-lualatex',
                }

                vim.g.vimtex_compiler_latexmk = {
                    continuous = 0,
                    callback = 1,
                    options = {
                        '-synctex=1',
                        '-interaction=nonstopmode',
                        '-file-line-error',
                    },
                }
                local sys = vim.loop.os_uname().sysname
                if sys == 'Darwin' then
                    vim.g.vimtex_view_method = 'skim'
                elseif sys == 'Linux' then
                    vim.g.vimtex_view_method = 'general'
                    vim.g.vimtex_view_general_viewer = 'okular'
                    vim.g.vimtex_view_general_options =
                        '--unique file:@pdf\\#src:@line@tex'
                    vim.g.vimtex_view_general_options_latexmk = '--unique'
                else
                    vim.g.vimtex_view_method = 'general'
                    vim.g.vimtex_view_general_viewer = 'open'
                end
            end,
        },
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
            keys = {
                {
                    '<leader>ff',
                    function()
                        require('telescope.builtin').find_files()
                    end,
                    desc = 'Telescope: Find files',
                },
                {
                    '<leader>fg',
                    function()
                        require('telescope.builtin').live_grep()
                    end,
                    desc = 'Telescope: Live grep',
                },
                {
                    '<leader>fb',
                    function()
                        require('telescope.builtin').buffers()
                    end,
                    desc = 'Telescope: Buffers',
                },

                {
                    'gd',
                    function()
                        require('telescope.builtin').lsp_definitions()
                    end,
                    desc = 'LSP: Go to definition (Telescope)',
                },
                {
                    'gr',
                    function()
                        require('telescope.builtin').lsp_references()
                    end,
                    desc = 'LSP: References (Telescope)',
                },
                {
                    'gi',
                    function()
                        require('telescope.builtin').lsp_implementations()
                    end,
                    desc = 'LSP: Implementations (Telescope)',
                },
                {
                    '<leader>ds',
                    function()
                        require('telescope.builtin').lsp_document_symbols()
                    end,
                    desc = 'LSP: Document symbols (Telescope)',
                },
                {
                    '<leader>ws',
                    function()
                        require('telescope.builtin').lsp_workspace_symbols()
                    end,
                    desc = 'LSP: Workspace symbols (Telescope)',
                },

                {
                    '<leader>gc',
                    function()
                        require('telescope.builtin').git_commits()
                    end,
                    desc = 'Git: Commit history (Telescope)',
                },
                {
                    '<leader>gs',
                    function()
                        require('telescope.builtin').git_status()
                    end,
                    desc = 'Git: Status (Telescope)',
                },
            },
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
                { 'hrsh7th/cmp-nvim-lua' },
                { 'hrsh7th/cmp-nvim-lsp' },
                { 'hrsh7th/cmp-nvim-lsp-signature-help' },
            },
            config = function()
                require('user.cmp')
                local caps = vim.lsp.protocol.make_client_capabilities()
                caps = require('cmp_nvim_lsp').default_capabilities(caps)
            end,
        },

        -- ------------------------------------------------------------
        -- LSP + LSPSaga + Mason
        -- ------------------------------------------------------------
        {
            'neovim/nvim-lspconfig',
            event = { 'BufReadPre', 'BufNewFile' },
            config = function()
                require('user.lsp')
            end,
        },
        {
            'nvimdev/lspsaga.nvim',
            event = 'LspAttach',
            config = function()
                require('user.lsp.lspsaga')
            end,
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
    },

    defaults = { lazy = true },
    install = { colorscheme = { 'darkplus' } },
})
