require('user.lsp.mason')
require('user.lsp.handlers').setup()

vim.api.nvim_create_user_command('LspHere', function()
    require('user.lsp.status').here()
end, {})
