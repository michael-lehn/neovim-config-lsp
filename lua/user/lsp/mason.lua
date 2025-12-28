-- Mason is used ONLY to install the server.
-- Neovim's native LSP (0.11+) does the rest.

local handlers = require('user.lsp.handlers')

-- ---------------------------------------------------------------------
-- Mason: package manager for LSP servers
-- ---------------------------------------------------------------------
require('mason').setup()

require('mason-lspconfig').setup({
    ensure_installed = {
        'lua_ls',
        'stylua',
    },
    automatic_installation = true,
})

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
