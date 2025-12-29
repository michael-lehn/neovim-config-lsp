vim.lsp.config('pyright', {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },

    root_dir = function(fname)
        return vim.fs.root(fname, {
            'pyproject.toml',
            'setup.py',
            'setup.cfg',
            'requirements.txt',
            '.git',
        }) or vim.fn.getcwd()
    end,

    settings = {
        python = {
            analysis = {
                -- "off" | "basic" | "standard" | "strict"
                typeCheckingMode = 'standard',
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                -- Let Ruff handle these:
                diagnosticSeverityOverrides = {},
            },
        },
    },
})

vim.lsp.config('ruff', {
    cmd = { 'ruff', 'server' },
    filetypes = { 'python' },
    settings = {
        lint = {
            select = { 'E', 'F' },
        },
    },
    root_dir = function(fname)
        return vim.fs.root(fname, {
            'pyproject.toml',
            'setup.py',
            'setup.cfg',
            'requirements.txt',
            '.git',
        }) or vim.fn.getcwd()
    end,
    cmd_env = {
        RUST_LOG = 'error',
    },
})

-- ---------------------------------------------------------------------
-- Start pyright reliably for Python buffers (no vim.lsp.enable needed)
-- ---------------------------------------------------------------------
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'python',
    callback = function(args)
        local have_pyright = false
        local have_ruff = false

        for _, c in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
            if c.name == 'pyright' then
                have_pyright = true
            elseif c.name == 'ruff' then
                have_ruff = true
            end
        end

        local fname = vim.api.nvim_buf_get_name(args.buf)

        -- -------------------------
        -- Start pyright (if needed)
        -- -------------------------
        if not have_pyright then
            if vim.fn.executable('pyright-langserver') == 0 then
                vim.notify(
                    'pyright-langserver not found in PATH',
                    vim.log.levels.WARN
                )
            else
                local cfg = vim.deepcopy(vim.lsp.config.pyright)

                local root = type(cfg.root_dir) == 'function'
                        and cfg.root_dir(fname)
                    or cfg.root_dir
                if not root or root == '' then
                    root = vim.fn.getcwd()
                end

                cfg.root_dir = root
                cfg.workspace_folders = {
                    { name = root, uri = vim.uri_from_fname(root) },
                }

                vim.lsp.start(cfg, { bufnr = args.buf })
            end
        end

        -- -------------------------
        -- Start ruff (if needed)
        -- -------------------------
        if not have_ruff then
            if vim.fn.executable('ruff') == 0 then
                vim.notify('ruff not found in PATH', vim.log.levels.WARN)
            else
                local cfg = vim.deepcopy(vim.lsp.config.ruff)

                local root = type(cfg.root_dir) == 'function'
                        and cfg.root_dir(fname)
                    or cfg.root_dir
                if not root or root == '' then
                    root = vim.fn.getcwd()
                end

                cfg.root_dir = root
                cfg.workspace_folders = {
                    { name = root, uri = vim.uri_from_fname(root) },
                }

                vim.lsp.start(cfg, { bufnr = args.buf })
            end
        end
    end,
})
