return {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop" },
    build = function()
        -- vim.fn["mkdp#util#install"]()
    end,
    config = function()
        -- Настройки переменных должны быть ДО загрузки плагина
        vim.g.mkdp_theme = 'dark'
        vim.g.mkdp_browser = '' -- Использовать системный браузер по умолчанию
        vim.g.mkdp_port = ''    -- Случайный порт
        vim.g.mkdp_page_title = '${name}'
        vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { "markdown" }, -- Опционально: загружать только для markdown файлов
    keys = {             -- Опционально: keymaps для ленивой загрузки
        { "<leader>mp", "<cmd>MarkdownPreview<cr>",     desc = "Markdown Preview" },
        { "<leader>ms", "<cmd>MarkdownPreviewStop<cr>", desc = "Markdown Preview Stop" },
    },
}
