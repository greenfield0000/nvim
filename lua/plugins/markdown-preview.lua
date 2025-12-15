return {
    'iamcco/markdown-preview.nvim',
    ft = { "markdown" },             -- загружать только для markdown файлов
    build = 'cd app && npm install', -- установка npm зависимостей после клона
    config = function()
        vim.g.mkdp_auto_start = 1    -- автостар при открытии markdown
        vim.g.mkdp_port = "8060"     -- порт по умолчанию
        vim.g.mkdp_theme = "dark"    -- тема превью (dark, light, auto)

        local map = function(mode, lhs, rhs, desc)
            if desc then desc = "Markdown preview: " .. desc end
            vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc})
        end

        map('n', '<leader>mp', "<cmd>MarkdownPreview<cr>", "Markdown preview")
    end,
}
