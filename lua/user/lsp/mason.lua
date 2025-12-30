-- Mason is used ONLY to install tools.
-- Neovim's native LSP (0.11+) does the rest.

local handlers = require('user.lsp.handlers')
local registry = require('mason-registry')

local function want_mason_pkg(pkg_name, bin_name)
    if vim.fn.executable(bin_name) == 1 then
        return false
    end
    return registry.has_package(pkg_name)
end

local function ensure_mason_pkgs(pkgs)
    for _, pkg in ipairs(pkgs) do
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

-- Lua LSP:
-- lsp server name: lua_ls
-- mason package name: lua-language-server
if want_mason_pkg('lua-language-server', 'lua-language-server') then
    table.insert(ensure_lsp_pkgs, 'lua-language-server')
end

-- clangd:
if want_mason_pkg('clangd', 'clangd') then
    table.insert(ensure_lsp_pkgs, 'clangd')
end

-- pyright:
if want_mason_pkg('pyright', 'pyright-langserver') then
    table.insert(ensure_lsp_pkgs, 'pyright')
end

-- ruff (binary provides ruff-lsp mode / native LSP in ruff):
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

-- Enable servers (LSP SERVER names!)
vim.lsp.enable('lua_ls')
vim.lsp.enable('clangd')
vim.lsp.enable('pyright')
vim.lsp.enable('ruff')
