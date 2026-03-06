return {
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup({
                ui = { border = "rounded" },
            })
        end,
    },
    {
        "mfussenegger/nvim-jdtls",
        dependencies = {
            "williamboman/mason.nvim",
            "mfussenegger/nvim-dap",
            "ray-x/lsp_signature.nvim",
            "neovim/nvim-lspconfig",
        },
    },
    -- {
    --     "ray-x/lsp_signature.nvim",
    --     config = function()
    --         require("lsp_signature").setup(
    --             {
    --                 bind = true,
    --                 doc_lines = 2,
    --                 max_height = 12,
    --                 max_width = 80,
    --                 handler_opts = {
    --                     border = "rounded",
    --                 },
    --                 always_trigger = true,
    --                 hint_prefix = "🡢 ",
    --                 -- Дополнительные опции:
    --                 floating_window = true, -- использовать всплывающее окно
    --                 floating_window_above_cursor = false, -- окно над курсором
    --                 fix_pos = false,    -- фиксировать позицию окна
    --                 hint_inside_word = true, -- показывать подсказки внутри слова
    --                 extra_hover_info = true, -- дополнительная информация при hover
    --                 zindex = 50,        -- z‑index окна
    --             }
    --         )
    --     end,
    -- },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "mfussenegger/nvim-jdtls",
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

                    map("n", "<leader>ch", vim.lsp.buf.hover, "[C]ode [H]over Documentation")
                    map("n", "<leader>cd", vim.lsp.buf.definition, "[C]ode Goto [D]efinition")
                    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ctions")
                    map("n", "<leader>cr", tbuiltin.lsp_references, "[C]ode Goto [R]eferences")
                    map("n", "<leader>ci", tbuiltin.lsp_implementations, "[C]ode Goto [I]mplementations")
                    map("n", "<leader>cR", vim.lsp.buf.rename, "[C]ode [R]ename")
                    map("n", "<leader>cD", vim.lsp.buf.declaration, "[C]ode Goto [D]eclaration")
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
                -- 'marksman',              -- для md (не работает json)
                'yamlls',        -- для yaml
            }

            local lspconf = require("lspconfig")

            for _, serv in ipairs(servers) do
                lspconf[serv].setup({
                    capabilities = capabilities,
                })
                -- vim.lsp.config('*', {
                --     capabilities = capabilities,
                -- })
            end
        end,
    },
}
