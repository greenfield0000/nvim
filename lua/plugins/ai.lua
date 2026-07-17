return {
    {
        "robitx/gp.nvim",
        event = "VeryLazy",
        config = function()
            require("gp").setup({
                providers = {
                    openai = { disable = true },
                    ollama = {
                        disable = false,
                        endpoint = "http://localhost:11434/api/chat",
                        secret = "dummy",
                    },
                },
                default_chat_agent = "OllamaChat",
                default_command_agent = "OllamaChat",
                agents = {
                    {
                        name = "OllamaChat",
                        provider = "ollama",
                        chat = true,
                        command = true,
                        model = { model = "qwen2.5-coder:7b", temperature = 0.3, top_p = 0.9 },
                        system_prompt = "You are a helpful coding assistant inside Neovim.",
                    },
                    {
                        name = "OllamaCoder",
                        provider = "ollama",
                        chat = true,
                        command = true,
                        model = { model = "qwen2.5-coder:7b", temperature = 0.2, top_p = 0.95 },
                        system_prompt = "You write precise, minimal code with brief explanations.",
                    },
                },
            })

            local map = vim.keymap.set
            map({ "n", "v" }, "<leader>ac", "<cmd>GpChatToggle<CR>", { desc = "AI: Переключить чат" })
            map({ "n", "v" }, "<leader>an", "<cmd>GpChatNew<CR>", { desc = "AI: Новый чат" })
            map({ "n", "v" }, "<leader>ar", "<cmd>GpRewrite<CR>", { desc = "AI: Rewrite выделенного" })
            map({ "n", "v" }, "<leader>ai", "<cmd>GpInline<CR>", { desc = "AI: Inline edit" })
            map({ "n", "v" }, "<leader>aa", "<cmd>GpAppend<CR>", { desc = "AI: Добавить ниже" })
            map({ "n", "v" }, "<leader>ap", "<cmd>GpPopup<CR>", { desc = "AI: Ответ в popup" })
        end,
    },
}
