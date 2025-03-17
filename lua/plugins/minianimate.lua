return {
    "echasnovski/mini.animate",
    event = "VeryLazy", -- Загружать плагин при неактивности
    config = function()
        require("mini.animate").setup({})
    end,
}
