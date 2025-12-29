vim.lsp.config('clangd', {
    cmd = {
        'clangd',
        '--background-index',
        '--clang-tidy',
        '--header-insertion=iwyu',
    },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
})
