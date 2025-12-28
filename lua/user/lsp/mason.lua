-- Mason is used ONLY to install the server.
-- Neovim's native LSP (0.11+) does the rest.

local handlers = require('user.lsp.handlers')

-- ---------------------------------------------------------------------
-- Mason: package manager for LSP servers
-- ---------------------------------------------------------------------
require('mason').setup()

local mlsp = require('mason-lspconfig')
local registry = require('mason-registry')

local function mason_available(pkgs)
    local out = {}
    for _, name in ipairs(pkgs) do
        if registry.has_package(name) then
            table.insert(out, name)
        end
        -- else: Paket existiert in Mason auf dieser Plattform nicht -> still skip
    end
    return out
end

mlsp.setup({
    ensure_installed = mason_available({
        'lua_ls',
        'stylua',
        'clangd',
        'clang-format',
    }),
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
