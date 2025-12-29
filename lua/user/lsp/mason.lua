-- Mason is used ONLY to install the server.
-- Neovim's native LSP (0.11+) does the rest.

local handlers = require('user.lsp.handlers')

-- ---------------------------------------------------------------------
-- Mason: package manager for LSP servers
-- ---------------------------------------------------------------------
require('mason').setup()

local mlsp = require('mason-lspconfig')
local registry = require('mason-registry')

local function want_mason_pkg(pkg_name, bin_name)
    if vim.fn.executable(bin_name) == 1 then
        return false
    end
    return registry.has_package(pkg_name)
end

-- lua LS
local ensure = { 'lua_ls' } -- LSP

-- C/C++ LS
if want_mason_pkg('clangd', 'clangd') then
    table.insert(ensure, 'clangd')
end

-- Python LS
if want_mason_pkg('pyright', 'pyright-langserver') then
    table.insert(ensure, 'pyright')
end

-- Ruff (native LSP lives inside the ruff binary): Diagnostics/Code Actions
if want_mason_pkg('ruff', 'ruff') then
    table.insert(ensure, 'ruff')
end

mlsp.setup({
    ensure_installed = ensure,
    automatic_enable = false,
    automatic_installation = false,
})

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

-- Python formatter
if want_mason_pkg('black', 'black') then
    table.insert(ensure_tools, 'black')
end

-- For sorting Python imports
if want_mason_pkg('isort', 'isort') then
    table.insert(ensure_tools, 'isort')
end

for _, pkg in ipairs(ensure_tools) do
    local ok, p = pcall(registry.get_package, pkg)
    if ok then
        -- install only if not installed
        if not p:is_installed() then
            p:install()
        end
    end
end

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

vim.lsp.enable('clangd')
