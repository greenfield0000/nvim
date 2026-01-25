return {
    -- Основной плагин для работы с Obsidian
    {
        'epwalsh/obsidian.nvim',
        dependencies = {
            "nvim-lua/plenary.nvim", -- обязательный плагин
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
    },
    -- Дополнительные плагины
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
    },
    {
        'nvim-autopairs',
        event = "InsertEnter",
    },
    {
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
    },
}
