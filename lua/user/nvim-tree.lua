local status_ok, nvim_tree = pcall(require, 'nvim-tree')
if not status_ok then
    vim.notify('nvim-tree plugin not installed')
    return
end

vim.keymap.set('n', '<C-e>', function()
    require('nvim-tree.api').tree.find_file({ open = true, focus = true })
end, { desc = 'NvimTree: Reveal current file' })

local function my_on_attach(bufnr)
    local api = require('nvim-tree.api')

    local function opts(desc)
        return {
            desc = 'nvim-tree: ' .. desc,
            buffer = bufnr,
            noremap = true,
            silent = true,
            nowait = true,
        }
    end

    -- default mappings
    -- api.config.mappings.default_on_attach(bufnr)

    -- custom mappings
    vim.keymap.set('n', '<2-LeftMouse>', api.node.open.edit, opts('Open'))
    vim.keymap.set('n', '<S-h>', 'gT', opts('Prev tab'))
    vim.keymap.set('n', '<S-l>', 'gt', opts('Next tab'))
    vim.keymap.set('n', '<S-Left>', 'gT', opts('Resize'))
    vim.keymap.set('n', '<S-Right>', 'gt', opts('Resize'))

    vim.keymap.set(
        'n',
        'x',
        api.node.navigate.parent_close,
        opts('Close Parent Node')
    )
    vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))

    vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
    vim.keymap.set('n', 's', function()
        local api = require('nvim-tree.api')

        -- Count "real" windows in the current tab (exclude the NvimTree window)
        local wins = vim.api.nvim_tabpage_list_wins(0)
        local file_wins = 0
        for _, win in ipairs(wins) do
            local b = vim.api.nvim_win_get_buf(win)
            local ft = vim.bo[b].filetype
            if ft ~= 'NvimTree' then
                file_wins = file_wins + 1
            end
        end

        if file_wins >= 2 then
            -- We already have at least two file windows
            -- → reuse/replace one (no new split)
            api.node.open.edit()
        else
            -- Only one file window → create a vertical split
            api.node.open.vertical()
        end
    end, opts('Open: Vertical Split'))
    vim.keymap.set('n', 't', api.node.open.tab, opts('Open: New Tab'))

    vim.keymap.set('n', 'a', api.fs.create, opts('Create'))
    vim.keymap.set('n', 'd', api.fs.remove, opts('Delete'))
    vim.keymap.set('n', 'm', api.fs.rename, opts('Move/Rename'))
    vim.keymap.set('n', 'c', function()
        local api = require('nvim-tree.api')
        local node = api.tree.get_node_under_cursor()

        if not node or not node.absolute_path then
            vim.notify('[nvim-tree] No node under cursor', vim.log.levels.WARN)
            return
        end

        local uv = vim.uv
        local src = node.absolute_path
        local src_stat = uv.fs_stat(src)
        if not src_stat then
            vim.notify(
                '[nvim-tree] Source does not exist',
                vim.log.levels.ERROR
            )
            return
        end

        local src_dir = vim.fs.dirname(src)
        local default_name = node.name

        local function ensure_dir(path)
            if uv.fs_stat(path) then
                return true
            end
            local ok, err = uv.fs_mkdir(path, 493) -- 0755
            if not ok and err ~= 'EEXIST' then
                return false, err
            end
            return true
        end

        local function copy_file(src_path, dst_path)
            if uv.fs_stat(dst_path) then
                local choice = vim.fn.confirm(
                    ('Overwrite?\n%s'):format(dst_path),
                    '&Yes\n&No',
                    2
                )
                if choice ~= 1 then
                    return true
                end
            end
            local ok, err = uv.fs_copyfile(src_path, dst_path)
            if not ok then
                return false, err
            end
            return true
        end

        local function copy_dir(src_path, dst_path)
            local ok, err = ensure_dir(dst_path)
            if not ok then
                return false, err
            end

            local iter, scan_err = uv.fs_scandir(src_path)
            if not iter then
                return false, scan_err or 'fs_scandir failed'
            end

            while true do
                local name, t = uv.fs_scandir_next(iter)
                if not name then
                    break
                end

                local child_src = src_path .. '/' .. name
                local child_dst = dst_path .. '/' .. name

                if t == 'directory' then
                    local ok2, err2 = copy_dir(child_src, child_dst)
                    if not ok2 then
                        return false, err2
                    end
                else
                    local ok2, err2 = copy_file(child_src, child_dst)
                    if not ok2 then
                        return false, err2
                    end
                end
            end

            return true
        end

        vim.ui.input(
            { prompt = 'Save as: ', default = default_name },
            function(name)
                if not name or name == '' then
                    return
                end

                -- If user enters only a name, copy into the same directory
                -- as the source
                local dst = name
                if not name:match('[/\\]') then
                    dst = src_dir .. '/' .. name
                end

                -- If copying a directory and dst exists, confirm overwrite-ish
                -- behavior
                if src_stat.type == 'directory' and uv.fs_stat(dst) then
                    local choice = vim.fn.confirm(
                        (
                            'Target exists:\n%s\n\nCopy into '
                            .. 'it / overwrite files as needed?'
                        ):format(dst),
                        '&Yes\n&No',
                        2
                    )
                    if choice ~= 1 then
                        return
                    end
                end

                local ok, err
                if src_stat.type == 'directory' then
                    ok, err = copy_dir(src, dst)
                else
                    -- file (or "link" etc.) -> treat as file copy
                    ok, err = copy_file(src, dst)
                end

                if not ok then
                    vim.notify(
                        ('[nvim-tree] Copy failed: %s'):format(
                            err or 'unknown error'
                        ),
                        vim.log.levels.ERROR
                    )
                    return
                end

                api.tree.reload()
                vim.notify(('[nvim-tree] Saved as %s'):format(dst))
            end
        )
    end, opts('Copy'))
end

nvim_tree.setup({
    on_attach = my_on_attach,
    update_focused_file = {
        enable = true,
        update_cwd = true,
    },
    renderer = {
        root_folder_modifier = ':t',
        icons = {
            glyphs = {
                default = '',
                symlink = '',
                folder = {
                    arrow_open = '',
                    arrow_closed = '',
                    default = '',
                    open = '',
                    empty = '',
                    empty_open = '',
                    symlink = '',
                    symlink_open = '',
                },
                git = {
                    unstaged = '',
                    staged = 'S',
                    unmerged = '',
                    renamed = '➜',
                    untracked = 'U',
                    deleted = '',
                    ignored = '◌',
                },
            },
        },
    },
    diagnostics = {
        enable = true,
        show_on_dirs = true,
        icons = {
            hint = '',
            info = '',
            warning = '',
            error = '',
        },
    },
    view = {
        width = 30,
        side = 'left',
    },
})

vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
        -- Nur aktuelle Tabpage betrachten
        local wins = vim.api.nvim_tabpage_list_wins(0)
        if #wins ~= 1 then
            return
        end

        local buf = vim.api.nvim_win_get_buf(wins[1])
        local ft = vim.bo[buf].filetype

        -- nvim-tree heißt als filetype normalerweise "NvimTree"
        if ft == 'NvimTree' then
            vim.cmd('quit')
        end
    end,
})
