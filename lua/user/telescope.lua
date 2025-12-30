local ok, builtin = pcall(require, 'telescope.builtin')
if not ok then
    vim.notify('cannot load telescope.builtin', vim.log.levels.WARN)
    return
end

-- Files / general
vim.keymap.set(
    'n',
    '<leader>ff',
    builtin.find_files,
    { desc = 'Telescope: Find files' }
)
vim.keymap.set(
    'n',
    '<leader>fg',
    builtin.live_grep,
    { desc = 'Telescope: Live grep' }
)
vim.keymap.set(
    'n',
    '<leader>fb',
    builtin.buffers,
    { desc = 'Telescope: Buffers' }
)
vim.keymap.set(
    'n',
    '<leader>fh',
    builtin.help_tags,
    { desc = 'Telescope: Help tags' }
)

-- LSP
vim.keymap.set(
    'n',
    'gd',
    builtin.lsp_definitions,
    { desc = 'LSP: Go to definition (Telescope)' }
)
vim.keymap.set(
    'n',
    'gr',
    builtin.lsp_references,
    { desc = 'LSP: References (Telescope)' }
)
vim.keymap.set(
    'n',
    'gi',
    builtin.lsp_implementations,
    { desc = 'LSP: Implementations (Telescope)' }
)
vim.keymap.set(
    'n',
    '<leader>ds',
    builtin.lsp_document_symbols,
    { desc = 'LSP: Document symbols (Telescope)' }
)
vim.keymap.set(
    'n',
    '<leader>ws',
    builtin.lsp_workspace_symbols,
    { desc = 'LSP: Workspace symbols (Telescope)' }
)
vim.keymap.set(
    'n',
    '<leader>gc',
    builtin.git_commits,
    { desc = 'Git: Commit history (Telescope)' }
)

vim.keymap.set(
    'n',
    '<leader>gs',
    builtin.git_status,
    { desc = 'Git: Status (Telescope)' }
)
