## Known Issues

### Arduino Language Server

Do **not** pass the default Neovim LSP capabilities to
`arduino-language-server`.

Recent versions of Neovim advertise semantic token support, causing
`arduino-language-server` to panic with

```
workspace/semanticTokens/refresh
```

and exit with code 2.

Either omit the `capabilities` field completely

```lua
vim.lsp.start({
    ...
})
```

or explicitly disable semantic token capabilities.
