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
-- Start pyright/ruff reliably for Python buffers
-- ---------------------------------------------------------------------
local group = vim.api.nvim_create_augroup('UserPythonLsp', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'python',
    callback = function(args)
        -- run once per buffer, even if FileType triggers again
        if vim.b[args.buf].user_python_lsp_started then
            return
        end
        vim.b[args.buf].user_python_lsp_started = true

        local fname = vim.api.nvim_buf_get_name(args.buf)

        local function compute_root(cfg)
            local root = (type(cfg.root_dir) == 'function')
                    and cfg.root_dir(fname)
                or cfg.root_dir
            if not root or root == '' then
                root = vim.fn.getcwd()
            end
            return root
        end

        local function ensure_client(name, cmd_check)
            for _, c in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
                if c.name == name then
                    return
                end
            end

            if vim.fn.executable(cmd_check) == 0 then
                vim.notify(
                    cmd_check .. ' not found in PATH',
                    vim.log.levels.WARN
                )
                return
            end

            local cfg = vim.deepcopy(vim.lsp.config[name])
            local root = compute_root(cfg)

            cfg.root_dir = root
            cfg.workspace_folders =
                { { name = root, uri = vim.uri_from_fname(root) } }

            vim.lsp.start(cfg, { bufnr = args.buf })
        end

        ensure_client('pyright', 'pyright-langserver')
        ensure_client('ruff', 'ruff')
    end,
})
