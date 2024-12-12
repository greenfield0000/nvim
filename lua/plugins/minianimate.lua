-- return {
--     {
--         'echasnovski/mini.animate',
--         opts = function()
--             local animate = require('mini.animate')
--
--             return {
--                 cursor = {
--                     enable = true,
--                     timing = animate.gen_timing.linear({ duration = 200, unit = 'total' }),
--                 },
--                 scroll = { enable = false },
--                 resize = { enable = false },
--                 open = { enable = true },
--                 close = { enable = true },
--             }
--         end
--     }
-- }
return {
    "echasnovski/mini.animate",
    event = "VeryLazy", -- Загружать плагин при неактивности
    config = function()
        require('mini.animate').setup({}
        -- {
        --     -- Настройки анимации
        --     cursor = {
        --         enable = true,  -- Включить анимацию каретки
        --         duration = 400, -- Длительность анимации в миллисекундах
        --     },
        --     scroll = {
        --         enable = true,  -- Включить анимацию прокрутки
        --         duration = 100, -- Длительность анимации прокрутки
        --     },
        --     resize = {
        --         enable = true,  -- Включить анимацию изменения размера
        --         duration = 100, -- Длительность анимации изменения размера
        --     },
        --     -- Другие настройки анимации можно добавить здесь
        -- }
        )
    end,
}
