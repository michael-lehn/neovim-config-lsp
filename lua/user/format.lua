vim.api.nvim_create_user_command('Format', function()
    local bufnr = vim.api.nvim_get_current_buf()
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
        return
    end

    vim.notify('No formatter configured for this filetype', vim.log.levels.WARN)
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
