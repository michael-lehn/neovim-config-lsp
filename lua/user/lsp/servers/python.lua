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
                typeCheckingMode = 'basic',
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
            },
        },
    },
})

-- ---------------------------------------------------------------------
-- Start pyright reliably for Python buffers (no vim.lsp.enable needed)
-- ---------------------------------------------------------------------
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'python',
    callback = function(args)
        -- Already attached?
        for _, c in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
            if c.name == 'pyright' then
                return
            end
        end

        -- If pyright-langserver is missing, don't try.
        if vim.fn.executable('pyright-langserver') == 0 then
            vim.notify(
                'pyright-langserver not found in PATH',
                vim.log.levels.WARN
            )
            return
        end

        local cfg = vim.deepcopy(vim.lsp.config.pyright)

        -- Compute root_dir NOW (important!)
        local fname = vim.api.nvim_buf_get_name(args.buf)
        local root = nil
        if type(cfg.root_dir) == 'function' then
            root = cfg.root_dir(fname)
        else
            root = cfg.root_dir
        end
        if not root or root == '' then
            root = vim.fn.getcwd()
        end

        cfg.root_dir = root
        cfg.workspace_folders = {
            { name = root, uri = vim.uri_from_fname(root) },
        }

        vim.lsp.start(cfg, { bufnr = args.buf })
    end,
})
