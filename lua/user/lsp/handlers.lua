local M = {}

M.capabilities = vim.lsp.protocol.make_client_capabilities()

do
    local ok, cmp = pcall(require, 'cmp_nvim_lsp')
    if ok then
        M.capabilities = cmp.default_capabilities(M.capabilities)
    end
end

local function buf_map(bufnr, mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, {
        buffer = bufnr,
        silent = true,
        noremap = true,
        desc = desc,
    })
end

function M.setup()
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
end

function M.on_attach(client, bufnr)
    -- ------------------------------------------------------------
    -- Clean separation: formatting is done ONLY via :Format
    -- (isort/black, stylua, clang-format). Never via LSP.
    -- ------------------------------------------------------------
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false

    -- Ruff should not "steal" hover; Pyright is better for that.
    if client.name == 'ruff' then
        client.server_capabilities.hoverProvider = false
    end

    -- LSP navigation / info
    buf_map(bufnr, 'n', 'gD', vim.lsp.buf.declaration, 'LSP: declaration')
    buf_map(bufnr, 'n', 'gd', vim.lsp.buf.definition, 'LSP: definition')
    buf_map(bufnr, 'n', 'gi', vim.lsp.buf.implementation, 'LSP: implementation')
    buf_map(bufnr, 'n', 'gr', vim.lsp.buf.references, 'LSP: references')

    -- Hover / signature with rounded borders (no global handler overrides)
    buf_map(bufnr, 'n', 'K', function()
        vim.lsp.buf.hover({ border = 'rounded' })
    end, 'LSP: hover')

    buf_map(bufnr, 'n', '<C-k>', function()
        vim.lsp.buf.signature_help({ border = 'rounded' })
    end, 'LSP: signature help')

    -- Diagnostics
    buf_map(bufnr, 'n', 'gl', vim.diagnostic.open_float, 'Diagnostics: line')

    buf_map(bufnr, 'n', '[d', function()
        vim.diagnostic.jump({ count = -1, float = { border = 'rounded' } })
    end, 'Diagnostics: prev')

    buf_map(bufnr, 'n', ']d', function()
        vim.diagnostic.jump({ count = 1, float = { border = 'rounded' } })
    end, 'Diagnostics: next')

    -- Format command
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function()
        if
            vim.bo[bufnr].filetype == 'c'
            or vim.bo[bufnr].filetype == 'cpp'
            or vim.bo[bufnr].filetype == 'objc'
            or vim.bo[bufnr].filetype == 'objcpp'
        then
            if vim.fn.executable('clang-format') == 0 then
                vim.notify(
                    'clang-format not found. Install via :MasonInstall '
                        .. 'clang-format (or your system package manager)',
                    vim.log.levels.ERROR
                )
                return
            end

            local view = vim.fn.winsaveview()
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local input = table.concat(lines, '\n')

            -- clang-format reads from stdin, writes to stdout
            local cmd = { 'clang-format' } -- optional: add style flags here
            local out = vim.fn.system(cmd, input)

            if vim.v.shell_error ~= 0 then
                vim.notify('clang-format failed', vim.log.levels.ERROR)
                return
            end

            local out_lines = vim.split(out, '\n', { plain = true })
            if out_lines[#out_lines] == '' then
                table.remove(out_lines, #out_lines)
            end

            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, out_lines)
            vim.fn.winrestview(view)
            return
        end

        if vim.bo[bufnr].filetype == 'python' then
            -- --- tools check
            if vim.fn.executable('isort') == 0 then
                vim.notify(
                    'isort not found. Install via pipx/pip/brew (recommended)'
                        .. ' or Mason if you use it',
                    vim.log.levels.ERROR
                )
                return
            end
            if vim.fn.executable('black') == 0 then
                vim.notify(
                    'black not found. Install via pipx/pip/brew (recommended)'
                        .. ' or Mason if you use it',
                    vim.log.levels.ERROR
                )
                return
            end

            local view = vim.fn.winsaveview()

            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local input = table.concat(lines, '\n')
            local fname = vim.api.nvim_buf_get_name(bufnr)

            -- --- 1) isort (stdin -> stdout)
            -- local res_isort = vim.system(
            --     { 'isort', '--filename', fname, '-' },
            --     { stdin = input, text = true }
            -- ):wait()

            -- if res_isort.code ~= 0 then
            --     vim.notify(
            --         'isort failed:\n' .. (res_isort.stderr or ''),
            --         vim.log.levels.ERROR
            --     )
            --     return
            -- end

            -- input = res_isort.stdout or input

            -- --- 2) black (stdin -> stdout)
            local res_black = vim.system(
                { 'black', '--quiet', '--stdin-filename', fname, '-' },
                { stdin = input, text = true }
            ):wait()

            if res_black.code ~= 0 then
                vim.notify(
                    'black failed:\n' .. (res_black.stderr or ''),
                    vim.log.levels.ERROR
                )
                return
            end

            local out = res_black.stdout or ''
            local out_lines = vim.split(out, '\n', { plain = true })
            if out_lines[#out_lines] == '' then
                table.remove(out_lines, #out_lines)
            end

            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, out_lines)
            vim.fn.winrestview(view)
            return
        end

        if vim.bo[bufnr].filetype == 'lua' then
            if vim.fn.executable('stylua') == 0 then
                vim.notify(
                    'stylua not found. Install via :MasonInstall stylua',
                    vim.log.levels.ERROR
                )
                return
            end

            local view = vim.fn.winsaveview()

            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local input = table.concat(lines, '\n')

            local res = vim.system(
                { 'stylua', '-' },
                { stdin = input, text = true }
            )
                :wait()

            if res.code ~= 0 then
                vim.notify(
                    'stylua failed:\n' .. (res.stderr or ''),
                    vim.log.levels.ERROR
                )
                return
            end

            -- Replace buffer content atomically
            local out = res.stdout or ''
            -- stylua typically ends with newline; keep buffer lines clean
            local out_lines = vim.split(out, '\n', { plain = true })
            if out_lines[#out_lines] == '' then
                table.remove(out_lines, #out_lines)
            end

            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, out_lines)
            vim.fn.winrestview(view)
            -- vim.api.nvim_exec_autocmds("TextChanged", { buffer = bufnr })
            return
        end

        vim.notify(
            'No formatter configured for this filetype',
            vim.log.levels.WARN
        )
    end, { desc = 'Format current buffer' })

    vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = bufnr,
        callback = function(args)
            if vim.bo[args.buf].buftype ~= '' then
                return
            end
            vim.cmd('Format')
        end,
    })
end

return M
