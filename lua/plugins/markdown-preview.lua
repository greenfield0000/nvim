return {
    'iamcco/markdown-preview.nvim',
    ft = { "markdown" },             -- загружать только для markdown файлов
    build = 'cd app && npm install', -- установка npm зависимостей после клона
    config = function()
        vim.g.mkdp_auto_start = 1    -- автостар при открытии markdown
        vim.g.mkdp_port = "8070"     -- порт по умолчанию
        vim.g.mkdp_theme = "dark"    -- тема превью (dark, light, auto)
    end,
}
