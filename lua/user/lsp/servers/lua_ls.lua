-- ---------------------------------------------------------------------
-- lua_ls configuration
-- ---------------------------------------------------------------------
vim.lsp.config('lua_ls', {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },

    -- Root logic:
    -- 1. Prefer a real project (.luarc.json / .git)
    -- 2. Otherwise treat your Neovim config as the project
    root_dir = function(fname)
        return vim.fs.root(fname, {
            '.luarc.json',
            '.luarc.jsonc',
            '.git',
        }) or vim.fn.stdpath('config')
    end,

    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' },
            },
            workspace = {
                library = {
                    [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                    [vim.fn.stdpath('config') .. '/lua'] = true,
                },
            },
        },
    },
})

-- ---------------------------------------------------------------------
-- Start lua_ls reliably for Lua buffers (no vim.lsp.enable needed)
-- ---------------------------------------------------------------------
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'lua',
    callback = function(args)
        -- Already attached?
        for _, c in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
            if c.name == 'lua_ls' then
                return
            end
        end

        local cfg = vim.deepcopy(vim.lsp.config.lua_ls)

        -- Compute a real root_dir NOW (important!)
        local fname = vim.api.nvim_buf_get_name(args.buf)
        local root = nil
        if type(cfg.root_dir) == 'function' then
            root = cfg.root_dir(fname)
        else
            root = cfg.root_dir
        end

        -- Fallback: directory of file (prevents empty workspace_folders)
        if not root or root == '' then
            if fname ~= '' then
                root = vim.fs.dirname(fname)
            else
                root = vim.uv.cwd()
            end
        end

        cfg.root_dir = root
        cfg.workspace_folders = {
            { name = root, uri = vim.uri_from_fname(root) },
        }

        vim.lsp.start(cfg, { bufnr = args.buf })
    end,
})

