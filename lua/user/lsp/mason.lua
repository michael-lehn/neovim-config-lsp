-- Mason is used ONLY to install tools.
-- Neovim's native LSP (0.11+) does the rest.

local handlers = require('user.lsp.handlers')

-- Ensure mason is loaded before we touch the registry.
local ok_mason, mason = pcall(require, 'mason')
if not ok_mason then
    return
end

-- If you configure mason via lazy's `opts`, this is optional.
-- But calling setup() twice is safe; mason will just reuse config.
pcall(mason.setup, {}) -- keep empty; lazy 'opts' will already apply

local ok_registry, registry = pcall(require, 'mason-registry')
if not ok_registry then
    return
end

local function strip_quotes(s)
    -- removes accidental leading/trailing quotes
    return (s:gsub('^%s*"(.*)"%s*$', '%1'):gsub("^%s*'(.*)'%s*$", '%1'))
end

local function want_mason_pkg(pkg_name, bin_name)
    pkg_name = strip_quotes(pkg_name)
    if vim.fn.executable(bin_name) == 1 then
        return false
    end
    return registry.has_package(pkg_name)
end

local function ensure_mason_pkgs(pkgs)
    for _, pkg in ipairs(pkgs) do
        pkg = strip_quotes(pkg)

        local ok, p = pcall(registry.get_package, pkg)
        if ok and not p:is_installed() then
            p:install()
        end
    end
end

-- -------------------------
-- LSP servers (Mason PACKAGE names!)
-- -------------------------
local ensure_lsp_pkgs = {}

if want_mason_pkg('lua-language-server', 'lua-language-server') then
    table.insert(ensure_lsp_pkgs, 'lua-language-server')
end

if want_mason_pkg('clangd', 'clangd') then
    table.insert(ensure_lsp_pkgs, 'clangd')
end

if want_mason_pkg('pyright', 'pyright-langserver') then
    table.insert(ensure_lsp_pkgs, 'pyright')
end

if want_mason_pkg('ruff', 'ruff') then
    table.insert(ensure_lsp_pkgs, 'ruff')
end

ensure_mason_pkgs(ensure_lsp_pkgs)

-- -------------------------
-- Non-LSP tools (formatters etc.)
-- -------------------------
local ensure_tools = {}

if want_mason_pkg('stylua', 'stylua') then
    table.insert(ensure_tools, 'stylua')
end

if want_mason_pkg('clang-format', 'clang-format') then
    table.insert(ensure_tools, 'clang-format')
end

if want_mason_pkg('black', 'black') then
    table.insert(ensure_tools, 'black')
end

if want_mason_pkg('isort', 'isort') then
    table.insert(ensure_tools, 'isort')
end

-- Tree-sitter CLI (needed to compile parsers)
if want_mason_pkg('tree-sitter-cli', 'tree-sitter') then
    table.insert(ensure_tools, 'tree-sitter-cli')
end

ensure_mason_pkgs(ensure_tools)

-- ---------------------------------------------------------------------
-- Global defaults for all LSP servers
-- ---------------------------------------------------------------------
vim.lsp.config('*', {
    on_attach = handlers.on_attach,
    capabilities = handlers.capabilities,
})

require('user.lsp.servers.lua_ls')
require('user.lsp.servers.clangd')
require('user.lsp.servers.python')

vim.lsp.enable('lua_ls')
vim.lsp.enable('clangd')
vim.lsp.enable('pyright')
vim.lsp.enable('ruff')
