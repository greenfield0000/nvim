return {
    "kdheepak/lazygit.nvim",
    cmd = {
        "LazyGit",
        "LazyGitConfig",
        "LazyGitCurrentFile",
        "LazyGitFilter",
        "LazyGitFilterCurrentFile",
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    keys = {
        { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit: git клиент" },
    },

    config = function()
        -- Настройки Lazygit
        vim.g.lazygit_floating_window_scaling_factor = 0.9
        vim.g.lazygit_floating_window_border = 'rounded'
        vim.g.lazygit_use_neovim_remote = 1
        vim.g.lazygit_floating_window_winblend = 0

        -- Локальные переменные для хранения оригинальных настроек
        local original_timeoutlen = vim.o.timeoutlen
        local original_ttimeoutlen = vim.o.ttimeoutlen

        -- Автоматическое исправление при открытии терминала
        vim.api.nvim_create_autocmd("TermOpen", {
            pattern = "*lazygit*",
            callback = function()
                vim.o.timeoutlen = 1000
                vim.o.ttimeoutlen = 1000
            end
        })

        -- Восстановление настроек после закрытия
        vim.api.nvim_create_autocmd("TermClose", {
            pattern = "*lazygit*",
            callback = function()
                vim.o.timeoutlen = original_timeoutlen
                vim.o.ttimeoutlen = original_ttimeoutlen
            end
        })

        -- Переопределяем команду для надежности
        vim.api.nvim_create_user_command("LazyGit", function()
            vim.o.timeoutlen = 1000
            vim.o.ttimeoutlen = 1000
            require("lazygit").lazygit()
        end, { desc = "Open LazyGit with escape fix" })
    end
}
