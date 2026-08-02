# Neovim LSP Configuration

This repository contains my personal Neovim LSP configuration.

The goal is to provide a lightweight and idiomatic setup for recent
Neovim versions. Rather than relying on the legacy `lspconfig.setup()`
interface, it uses the built-in APIs introduced in Neovim 0.11 and
later, such as `vim.lsp.enable()` and `vim.lsp.start()`.

## Features

-   Uses Neovim's native LSP client.
-   No `lspconfig.setup()` compatibility layer.
-   Automatic server installation via Mason.
-   Simple configuration with one file per language server.
-   Supports both static (`vim.lsp.enable()`) and dynamic
    (`vim.lsp.start()`) server configuration.
-   Keeps language-specific workarounds local to the corresponding
    server.

Currently the configuration includes support for:

-   Lua (`lua_ls`)
-   C/C++ (`clangd`)
-   Python (`pyright` and `ruff`)
-   Arduino (`arduino-language-server`)

## Arduino Language Server

Do **not** pass the default Neovim LSP capabilities to
`arduino-language-server`.

Recent versions of Neovim advertise semantic token support, causing
`arduino-language-server` to panic with

``` text
workspace/semanticTokens/refresh
```

and exit with code 2.

Either omit the `capabilities` field completely or explicitly disable
semantic token capabilities.

