-- Only run MasonInstall when something is missing.
-- This avoids the "slow every start" problem and avoids registry timing issues.

if not pcall(require, 'mason') then
    return
end

local pkgs = {
    'lua-language-server',
    'clangd',
    'pyright',
    'ruff',
    'stylua',
    'clang-format',
    'black',
    'isort',
    'tree-sitter-cli',
}

local function pkg_installed(name)
    local dir = vim.fn.stdpath('data') .. '/mason/packages/' .. name
    return (vim.uv or vim.loop).fs_stat(dir) ~= nil
end

local function any_missing()
    for _, name in ipairs(pkgs) do
        if not pkg_installed(name) then
            return true
        end
    end
    return false
end

vim.schedule(function()
    if vim.fn.exists(':MasonInstall') ~= 2 then
        return
    end

    -- Optional: only attempt installs once per session
    if vim.g._mason_bootstrap_ran then
        return
    end
    vim.g._mason_bootstrap_ran = true

    if any_missing() then
        vim.cmd('MasonInstall ' .. table.concat(pkgs, ' '))
    end
end)
