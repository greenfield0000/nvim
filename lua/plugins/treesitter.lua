return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    branch = "main",
    commit = "42fc28ba918343ebfd5565147a42a26580579482",
    dependencies = {
        -- ts-autotag использует treesitter для понимания структуры кода, чтобы автоматически закрывать теги tsx
        "windwp/nvim-ts-autotag"
    },
    -- при сборке плагина запустите команду TSUpdate, чтобы убедиться, что все наши серверы установлены и обновлены
    build = ':TSUpdate',
    config = function()
        -- получаем доступ к функциям конфигурации treesitter
        local ts_config = require("nvim-treesitter.configs")

        -- вызываем функцию настройки treesitter с параметрами для настройки нашего опыта
        ts_config.setup({
            -- убедитесь, что у нас установлены необходимые парсеры
            ensure_installed = {
                "vim",
                "go",
                "vimdoc",
                "lua",
                "java",
                "javascript",
                "typescript",
                "html",
                "css",
                "json",
                "tsx",
                -- "markdown",
                -- "markdown_inline",
                "gitignore",
                "sql",
            },
            preview = { treesitter = false },
            -- убедитесь, что подсветка включена
            highlight = { enable = true },
            -- включите автоматическое закрытие тегов tsx
            autotag = {
                enable = true
            }
        })
    end
}
