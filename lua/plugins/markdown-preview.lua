return {
    -- Основной плагин для работы с Obsidian
    {
        'epwalsh/obsidian.nvim',
        dependencies = {
            "nvim-lua/plenary.nvim", -- обязательный плагин
            'nvim-treesitter/nvim-treesitter',
            'hrsh7th/nvim-cmp',
            'nvim-autopairs',
            'iamcco/markdown-preview.nvim',
        },
        event = "BufReadPre *.md",
        config = function()
            require('obsidian').setup({
                dir = '~/obsidian',
                notes_dir = '', -- директория для заметок (оставьте пустой для корня)
                markdown_preview_cmd = 'markdown-preview.nvim',
            })
        end,
    },
    -- Предпросмотр Markdown
    {
        'iamcco/markdown-preview.nvim',
        ft = 'markdown',
        build = function()
            pcall(vim.fn['mkdp#util#install'])
        end,
    }
}
