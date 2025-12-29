require('which-key').setup({
    plugins = {
        marks = false,
        registers = false,
        spelling = false,
    },
    presets = {
        operators = false,
        motions = false,
        text_objects = false,
    },
    win = {
        border = 'single',
    },
    delay = 500,
})
