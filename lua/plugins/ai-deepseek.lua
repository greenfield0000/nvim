-- в lazy.nvim
return {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
        local api_key = os.getenv("DEEPSEEK_SECRET_API")
        require("chatgpt").setup({
            api_key_cmd = "echo " .. api_key,
            openai_params = {
                model = "deepseek-chat",
                max_tokens = 1000,
            },
            openai_edit_params = {
                model = "deepseek-chat",
            },
        })
    end,
    dependencies = {
        "MunifTanjim/nui.nvim",
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim"
    }
}
