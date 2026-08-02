vim.diagnostic.config({
    virtual_text = false,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.HINT] = '',
            [vim.diagnostic.severity.INFO] = '',
        },
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
        focusable = false,
        style = 'minimal',
        border = 'rounded',
        source = true, -- 0.11+: boolean or "if_many"
        header = '',
        prefix = '',
    },
})

local capabilities = vim.lsp.protocol.make_client_capabilities()

vim.lsp.config('clangd', {
    capabilities = capabilities,
    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local root = vim.fs.root(fname, {
            '.clangd',
            'compile_commands.json',
            'compile_flags.txt',
            '.git',
        })
        on_dir(root or vim.fs.dirname(fname))
    end,
})

vim.lsp.config('lua_ls', {
    capabilities = capabilities,
})

vim.lsp.config('pyright', {
    capabilities = capabilities,
})

vim.lsp.config('ruff', {
    capabilities = capabilities,
})

vim.lsp.config('arduino_language_server', {
    capabilities = capabilities,

    filetypes = { 'arduino' },

    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)

        local root = vim.fs.root(fname, {
            'sketch.yaml',
            '.git',
        })

        on_dir(root or vim.fs.dirname(fname))
    end,

    cmd = {
        'arduino-language-server',
        '-cli',
        'arduino-cli',
        '-cli-config',
        vim.fn.expand('~/Library/Arduino15/arduino-cli.yaml'),
        '-clangd',
        'clangd',
        '-fqbn',
        'arduino:avr:uno',
    },
})

local ft_to_server = {
    c = 'clangd',
    cpp = 'clangd',
    lua = 'lua_ls',
    python = 'pyright',
}

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'c', 'cpp', 'lua', 'python' },
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        local server = ft_to_server[ft]
        if not server then
            return
        end

        local cfg = vim.lsp.config[server]
        if not cfg then
            vim.notify(
                'No LSP config found for ' .. server,
                vim.log.levels.ERROR
            )
            return
        end

        vim.lsp.start(cfg, { bufnr = args.buf })
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'arduino',

    callback = function(args)
        local fname = vim.api.nvim_buf_get_name(args.buf)
        local root = vim.fs.dirname(fname)

        vim.lsp.start({
            name = 'arduino_language_server',

            capabilities = capabilities,

            cmd = {
                'arduino-language-server',

                '-cli',
                'arduino-cli',

                '-cli-config',
                vim.fn.expand('~/Library/Arduino15/arduino-cli.yaml'),

                '-clangd',
                'clangd',

                '-fqbn',
                'arduino:avr:uno',
            },

            root_dir = root,
        }, {
            bufnr = args.buf,
        })
    end,
})
