local colorscheme = 'darkplus'
-- local colorscheme = 'bearded'
-- local colorscheme = 'onedark'
-- local colorscheme = 'onedark'

local status_ok, _ = pcall(function()
    vim.cmd('colorscheme ' .. colorscheme)
end)
if not status_ok then
    vim.notify('colorscheme ' .. colorscheme .. ' not found!')
    return
end
