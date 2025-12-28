local opts = { noremap = true, silent = true }

local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
keymap('', '<Space>', '<Nop>', opts)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- Better window navigation
keymap('n', '<C-Left>', '<C-w>h', opts)
keymap('n', '<C-Down>', '<C-w>j', opts)
keymap('n', '<C-Up>', '<C-w>k', opts)
keymap('n', '<C-Right>', '<C-w>l', opts)
keymap('n', '<C-h>', '<C-w>h', opts)
keymap('n', '<C-j>', '<C-w>j', opts)
keymap('n', '<C-k>', '<C-w>k', opts)
keymap('n', '<C-l>', '<C-w>l', opts)
keymap('n', '<S-Left>', 'gT', opts)
keymap('n', '<S-Right>', 'gt', opts)
keymap('n', '<S-h>', 'gT', opts)
keymap('n', '<S-l>', 'gt', opts)


-- Navigate buffers
keymap('n', '<S-Up>', ':bprevious<CR>', opts)
keymap('n', '<S-Down>', ':bnext<CR>', opts)

-- hide last search
keymap('n', '<Esc>', ':noh<cr>', opts)

keymap('n', '<leader>e', ':NvimTreeToggle<cr>', opts)

-- Insert --

-- Visual --
-- Stay in indent mode
keymap('v', '<', '<gv', opts)
keymap('v', '>', '>gv', opts)

-- Move text up and down
keymap('v', 'p', '"_dP', opts)
keymap('v', '<J>', ':m .+1<CR>==', opts)
keymap('v', '<K>', ':m .-2<CR>==', opts)

-- Visual Block --
-- Move text up and down
keymap('x', 'J', ":move '>+1<CR>gv-gv", opts)
keymap('x', 'K', ":move '<-2<CR>gv-gv", opts)

-- Terminal --
-- Better terminal navigation
keymap('t', '<C-h>', '<C-\\><C-N><C-w>h', term_opts)
keymap('t', '<C-j>', '<C-\\><C-N><C-w>j', term_opts)
keymap('t', '<C-k>', '<C-\\><C-N><C-w>k', term_opts)
keymap('t', '<C-l>', '<C-\\><C-N><C-w>l', term_opts)
