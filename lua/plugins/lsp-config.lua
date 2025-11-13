return {
    -- utility plugin for configuring the java language server for us
    {
        "mfussenegger/nvim-jdtls",
        -- dependencies = {
        --     "mfussenegger/nvim-dap",
        --     "ray-x/lsp_signature.nvim",
        -- },
    },
    {
        "ray-x/lsp_signature.nvim",
        config = function()
            require("lsp_signature").setup()
        end,
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            { "antosha417/nvim-lsp-file-operations", config = true },
        },
        config = function()
            -- NOTE: LSP Keybinds
            -- Set vim motion for <Space> + c + h to show code documentation about the code the cursor is currently over if available
            vim.keymap.set("n", "<leader>ch", vim.lsp.buf.hover, { desc = "[C]ode [H]over Documentation" })
            -- Set vim motion for <Space> + c + d to go where the code/variable under the cursor was defined
            vim.keymap.set("n", "<leader>cd", vim.lsp.buf.definition, { desc = "[C]ode Goto [D]efinition" })
            -- Set vim motion for <Space> + c + a for display code action suggestions for code diagnostics in both normal and visual mode
            vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "[C]ode [A]ctions" })
            -- Set vim motion for <Space> + c + r to display references to the code under the cursor
            vim.keymap.set(
                "n",
                "<leader>cr",
                require("telescope.builtin").lsp_references,
                { desc = "[C]ode Goto [R]eferences" }
            )
            -- Set vim motion for <Space> + c + i to display implementations to the code under the cursor
            vim.keymap.set(
                "n",
                "<leader>ci",
                require("telescope.builtin").lsp_implementations,
                { desc = "[C]ode Goto [I]mplementations" }
            )
            -- Set a vim motion for <Space> + c + <Shift>R to smartly rename the code under the cursor
            vim.keymap.set("n", "<leader>cR", vim.lsp.buf.rename, { desc = "[C]ode [R]ename" })
            -- Set a vim motion for <Space> + c + <Shift>D to go to where the code/object was declared in the project (class file)
            vim.keymap.set("n", "<leader>cD", vim.lsp.buf.declaration, { desc = "[C]ode Goto [D]eclaration" })

            -- Define sign icons for each severity
            local signs = {
                [vim.diagnostic.severity.ERROR] = " ",
                [vim.diagnostic.severity.WARN] = " ",
                [vim.diagnostic.severity.HINT] = "󰠠 ",
                [vim.diagnostic.severity.INFO] = " ",
            }

            -- Set diagnostic config
            vim.diagnostic.config({
                signs = {
                    text = signs,
                },
                virtual_text = true,
                underline = true,
                update_in_insert = false,
            })

            -- Setup servers
            local cmp_nvim_lsp = require("cmp_nvim_lsp")
            local capabilities = cmp_nvim_lsp.default_capabilities()

            -- Global LSP settings (applied to all servers)
            vim.lsp.config('*', {
                capabilities = capabilities,
            })
        end,
    },
}
