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
                    "buf",                        -- protobuf
                    "angular-language-server",    -- angular
                    "typescript-language-server", -- angular
                    "docker-language-server",     -- dockerfile, docker
                    "sqlls",                      -- sql
                    "marksman",                   -- md
                    -- Linter
                    -- "ast-grep",                   -- many lang java, golang, c++, rust
                    "sqlfluff",           -- sql
                    "checkmake",          -- makefile
                    -- dap
                    "go-debug-adapter",   -- many lang java, golang, c++, rust
                    "java-debug-adapter", -- many lang java, golang, c++, rust
                    -- test
                    "java-test",
                    -- formatter
                    "xmlformatter",
                },
            })
        end,
    },
}
