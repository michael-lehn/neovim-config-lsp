local M = {}

function M.bootstrap()
    -- Mason ist optional: wenn nicht installiert/geladen, einfach nichts tun
    if not pcall(require, 'mason') then
        return
    end

    -- Map: mason package name -> executable to check in $PATH
    local pkgs = {
        { pkg = 'lua-language-server', exe = 'lua-language-server' },
        { pkg = 'clangd', exe = 'clangd', mason_optional = true },
        { pkg = 'pyright', exe = 'pyright-langserver' },
        { pkg = 'ruff', exe = 'ruff' },
        { pkg = 'stylua', exe = 'stylua' },
        { pkg = 'clang-format', exe = 'clang-format' },
        { pkg = 'black', exe = 'black' },
        { pkg = 'isort', exe = 'isort' },
    }

    local function mason_pkg_installed(name)
        local dir = vim.fn.stdpath('data') .. '/mason/packages/' .. name
        return (vim.uv or vim.loop).fs_stat(dir) ~= nil
    end

    local function system_has(exe)
        return vim.fn.executable(exe) == 1
    end

    vim.schedule(function()
        if vim.fn.exists(':MasonInstall') ~= 2 then
            return
        end
        if vim.g._mason_bootstrap_ran then
            return
        end
        vim.g._mason_bootstrap_ran = true

        local no_clangd = vim.g.mason_no_clangd == true
        local to_install = {}

        for _, item in ipairs(pkgs) do
            local pkg = item.pkg
            local exe = item.exe

            if system_has(exe) then
                goto continue
            end
            if mason_pkg_installed(pkg) then
                goto continue
            end
            if pkg == 'clangd' and no_clangd then
                goto continue
            end

            table.insert(to_install, pkg)
            ::continue::
        end

        if #to_install > 0 then
            vim.cmd('MasonInstall ' .. table.concat(to_install, ' '))
        end
    end)
end

return M
