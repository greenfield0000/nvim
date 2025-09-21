return {
    "echasnovski/mini.animate",
    event = "VeryLazy",
    config = function()
        require("mini.animate").setup({
            cursor = { enable = true },    -- Отключить анимацию курсора
            scroll = { enable = true },     -- Включить только скролл
            resize = { enable = true },    -- Отключить resize
            open = { enable = true },      -- Отключить открытие
            close = { enable = true },     -- Отключить закрытие
        })
    end,
}
