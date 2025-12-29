local M = {}

function M.here()
    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.bo[bufnr].filetype
    local name = vim.api.nvim_buf_get_name(bufnr)

    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    if #clients == 0 then
        vim.notify(
            ('No LSP clients attached\nfiletype=%s\nbuffer=%s'):format(ft, name),
            vim.log.levels.WARN
        )
        return
    end

    local lines = {}
    table.insert(lines, ('filetype=%s'):format(ft))
    table.insert(lines, ('buffer=%s'):format(name))
    table.insert(lines, 'clients:')

    for _, c in ipairs(clients) do
        local cmd = ''
        if c.config and c.config.cmd then
            cmd = table.concat(c.config.cmd, ' ')
        end
        table.insert(
            lines,
            ('  - %s (id=%d) root=%s cmd=%s'):format(
                c.name,
                c.id,
                c.config and c.config.root_dir or '?',
                cmd ~= '' and cmd or '?'
            )
        )
    end

    vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO)
end

return M
