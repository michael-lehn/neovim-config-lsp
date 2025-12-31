-- require('user.lsp.mason')
require('user.lsp.handlers').setup()
require('user.lsp.lspsaga')

vim.api.nvim_create_user_command('LspHere', function()
    require('user.lsp.status').here()
end, {})

local handlers = require('user.lsp.handlers')

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
