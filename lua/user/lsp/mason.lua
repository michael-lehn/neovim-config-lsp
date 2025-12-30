-- Install missing tools via Mason, but:
-- - skip if already available system-wide
-- - skip if already installed by Mason
-- - install ONLY the missing ones
-- - optionally: never try Mason for clangd (Pi 5 workaround)

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
    { pkg = 'tree-sitter-cli', exe = 'tree-sitter' },
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

    -- If clangd regularly fails on your Pi, set this global there:
    --   vim.g.mason_no_clangd = true
    -- e.g. in a hostname-based machine file or just in that system's config.
    local no_clangd = vim.g.mason_no_clangd == true

    local to_install = {}

    for _, item in ipairs(pkgs) do
        local pkg = item.pkg
        local exe = item.exe

        -- 1) already available system-wide? -> skip
        if system_has(exe) then
            goto continue
        end

        -- 2) already installed by mason? -> skip
        if mason_pkg_installed(pkg) then
            goto continue
        end

        -- 3) optional policy: never try clangd via mason on some machines
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
