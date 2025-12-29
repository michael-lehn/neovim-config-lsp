require('lualine').setup({
    options = {
        icons_enabled = true,
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        always_divide_middle = true,
        disabled_filetypes = {
            statusline = {
                'fugitive',
                'gitcommit',
                'help',
                'NvimTree',
                'neo-tree',
                'TelescopePrompt',
            },
            winbar = { 'fugitive' },
        },
    },
})
