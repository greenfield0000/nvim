return {
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup({
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗",
                    },
                },
            })
        end,
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        config = function()
            require("mason-tool-installer").setup({
                ensure_installed = {
                    -- LSP
                    "lua-language-server",        -- lua
                    "gopls",                      -- golang
                    "json-lsp",                   -- json
                    "jdtls",                      -- java
                    "lemminx",                    -- xml
                    "angular-language-server",    -- angular
                    "typescript-language-server", -- ts
                    "dockerfile-language-server", -- dockerfile, docker
                    "yaml-language-server",       -- yaml
                    "sqlls",                      -- sql
                    "marksman",                   -- md
                    -- Linter
                    "sqlfluff",                   -- sql
                    "checkmake",                  -- makefile
                    -- dap
                    "delve",                      -- golang debug
                    "java-debug-adapter",         -- many lang java, golang, c++, rust
                    -- test
                    "java-test",
                },
            })
        end,
    },
}
