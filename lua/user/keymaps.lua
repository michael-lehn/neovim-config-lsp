-- Remap <Space> as leader key (must be set early)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Disable Space in normal/visual/etc. so it can be leader
map({ 'n', 'v', 'x', 'o' }, '<Space>', '<Nop>', opts)

-- ------------------------------------------------------------
-- Normal mode
-- ------------------------------------------------------------

-- Better window navigation
map('n', '<C-Left>', '<C-w>h', opts)
map('n', '<C-Down>', '<C-w>j', opts)
map('n', '<C-Up>', '<C-w>k', opts)
map('n', '<C-Right>', '<C-w>l', opts)

map('n', '<C-h>', '<C-w>h', opts)
map('n', '<C-j>', '<C-w>j', opts)
map('n', '<C-k>', '<C-w>k', opts)
map('n', '<C-l>', '<C-w>l', opts)

-- Tab navigation
map('n', '<S-Left>', 'gT', opts)
map('n', '<S-Right>', 'gt', opts)
map('n', '<S-h>', 'gT', opts)
map('n', '<S-l>', 'gt', opts)

-- Buffer navigation
map('n', '<S-Up>', ':bprevious<CR>', opts)
map('n', '<S-Down>', ':bnext<CR>', opts)

-- Hide last search highlight
map('n', '<Esc>', ':nohlsearch<CR>', opts)

-- NvimTree
map('n', '<leader>e', ':NvimTreeToggle<CR>', opts)

-- ------------------------------------------------------------
-- Visual mode
-- ------------------------------------------------------------

-- Stay in indent mode
map('v', '<', '<gv', opts)
map('v', '>', '>gv', opts)

-- Paste without yanking replaced text
map('v', 'p', '"_dP', opts)

-- Move selected text up/down (visual)
map('v', '<J>', ":m '>+1<CR>==", opts)
map('v', '<K>', ":m '<-2<CR>==", opts)

-- ------------------------------------------------------------
-- Visual block mode
-- ------------------------------------------------------------
map('x', 'J', ":move '>+1<CR>gv-gv", opts)
map('x', 'K', ":move '<-2<CR>gv-gv", opts)

-- ------------------------------------------------------------
-- Insert mode
-- ------------------------------------------------------------
--
-- Better window navigation
map('i', '<C-Left>', '<Esc><C-w>h', opts)
map('i', '<C-Down>', '<Esc><C-w>j', opts)
map('i', '<C-Up>', '<Esc><C-w>k', opts)
map('i', '<C-Right>', '<Esc><C-w>l', opts)

map('i', '<C-h>', '<Esc><C-w>h', opts)
map('i', '<C-j>', '<Esc><C-w>j', opts)
map('i', '<C-k>', '<Esc><C-w>k', opts)
map('i', '<C-l>', '<Esc><C-w>l', opts)

-- Tab navigation
map('i', '<S-Left>', '<Esc>gT', opts)
map('i', '<S-Right>', '<Esc>gt', opts)
