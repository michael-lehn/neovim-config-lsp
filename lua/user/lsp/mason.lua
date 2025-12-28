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

local ensure = { 'lua_ls' }  -- LSP

if want_mason_pkg('stylua', 'stylua') then
    table.insert(ensure, 'stylua')
end

if want_mason_pkg('clang-format', 'clang-format') then
    table.insert(ensure, 'clang-format')
end

if want_mason_pkg('clangd', 'clangd') then
    table.insert(ensure, 'clangd')
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

vim.lsp.enable('clangd')
