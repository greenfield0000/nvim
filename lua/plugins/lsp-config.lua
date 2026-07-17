return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
        },

        config = function()
            local icons = require("icons")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- сохраним capabilities глобально, чтобы использовать в ftplugin
            vim.g.lsp_capabilities = capabilities

            local default_diagnostic_config = {
                signs = {
                    active = true,
                    values = {
                        { name = "DiagnosticSignError", text = icons.diagnostics.Error },
                        { name = "DiagnosticSignWarn",  text = icons.diagnostics.Warning },
                        { name = "DiagnosticSignHint",  text = icons.diagnostics.Hint },
                        { name = "DiagnosticSignInfo",  text = icons.diagnostics.Information },
                    },
                },
                virtual_text = true,
                update_in_insert = false,
                underline = true,
                severity_sort = true,
                float = {
                    focusable = true,
                    style = "minimal",
                    border = "rounded",
                    source = "always",
                    header = "",
                    prefix = "",
                },
            }

            vim.diagnostic.config(default_diagnostic_config)

            for _, sign in ipairs(vim.tbl_get(vim.diagnostic.config(), "signs", "values") or {}) do
                vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
            end

            -- Глобальные биндинги по LspAttach, чтобы не развозить их по ftplugin
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local bufnr = args.buf
                    local tbuiltin = require("telescope.builtin")

                    local map = function(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
                    end

                    map("n", "<leader>ch", vim.lsp.buf.hover, "LSP: Hover документация")
                    map("n", "<leader>cd", vim.lsp.buf.definition, "LSP: Перейти к definition")
                    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP: Code actions")
                    map("n", "<leader>cr", tbuiltin.lsp_references, "LSP: Найти references")
                    map("n", "<leader>ci", tbuiltin.lsp_implementations, "LSP: Найти implementations")
                    map("n", "<leader>cR", vim.lsp.buf.rename, "LSP: Rename symbol")
                    map("n", "<leader>cD", vim.lsp.buf.declaration, "LSP: Перейти к declaration")
                    map({ "n", "v" }, "<leader>cf", vim.lsp.buf.format, "LSP: Format кода")
                    map("n", "<leader>ct", vim.lsp.buf.type_definition, "LSP: Перейти к type definition")
                    map("n", "<leader>cds", vim.lsp.buf.document_symbol, "LSP: Document symbol")
                    map("n", "<leader>csh", vim.lsp.buf.signature_help, "LSP: Signature help")
                end,
            })

            local servers = {
                'lua_ls',        -- для lua
                'lemminx',       -- для xml
                'jsonls',        -- для json
                'sqlls',         -- для sql
                'rust_analyzer', -- для rust
                'gopls',         -- для golang
                'angularls',     -- для ангуляр
                'yamlls',        -- для yaml
                'marksman',      -- markdown
                'html',          -- markdown
                'ts_ls',         -- typescript
                'dotls',         -- dot
                'dockerls',      -- docker
            }

            local lspconf = require("lspconfig")
            for _, serv in ipairs(servers) do
                vim.lsp.enable(serv)
            end
        end,
    },
}
