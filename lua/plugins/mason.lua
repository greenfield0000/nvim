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
                    "lua-language-server",
                    "gopls",
                    "json-lsp",
                    "jdtls",
                    "lemminx",
                },
            })
        end,
    },
    -- mason nvim dap utilizes mason to automatically ensure debug adapters you want installed are installed,
    -- mason-lspconfig will not automatically install debug adapters for us
    {
        "jay-babu/mason-nvim-dap.nvim",
        config = function()
            -- ensure the java debug adapter is installed
            require("mason-nvim-dap").setup({
                ensure_installed = {
                    "java-debug-adapter",
                    "java-test",
                },
            })
        end,
    },
}
